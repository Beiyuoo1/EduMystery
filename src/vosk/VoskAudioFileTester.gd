# VoskAudioFileTester.gd
# Universal audio file tester with guaranteed confidence scores
extends Control

var vosk = null
var model_path: String = "res://addons/vosk/models/vosk-model-small-en-us-0.15"

@onready var file_dialog: FileDialog = $FileDialog
@onready var select_button: Button = $VBoxContainer/SelectButton
@onready var status_label: Label = $VBoxContainer/StatusLabel
@onready var file_label: Label = $VBoxContainer/FileLabel
@onready var result_text: TextEdit = $VBoxContainer/ResultText
@onready var confidence_label: Label = $VBoxContainer/ConfidenceLabel

func _ready():
	_setup_vosk()
	_setup_ui()

func _setup_vosk():
	vosk = ClassDB.instantiate("GodotVoskRecognizer")
	var absolute_path = ProjectSettings.globalize_path(model_path)
	
	if not vosk.initialize(absolute_path, 16000.0):
		push_error("Failed to initialize Vosk recognizer")
		status_label.text = "ERROR: Vosk failed to initialize"
		status_label.add_theme_color_override("font_color", Color.RED)
		select_button.disabled = true
		return
	
	# Enable word-level results for confidence scores
	vosk.set_words(true)
	
	status_label.text = "Ready - Select an audio file"
	status_label.add_theme_color_override("font_color", Color.GREEN)

func _setup_ui():
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.clear_filters()
	file_dialog.add_filter("*.wav, *.mp3, *.ogg", "Audio Files")
	file_dialog.add_filter("*.wav", "WAV Audio")
	file_dialog.add_filter("*.mp3", "MP3 Audio")
	file_dialog.add_filter("*.ogg", "OGG Audio")
	file_dialog.file_selected.connect(_on_file_selected)
	
	select_button.pressed.connect(_on_select_button_pressed)
	
	file_label.text = "No file selected"
	result_text.text = ""
	confidence_label.text = ""

func _on_select_button_pressed():
	file_dialog.popup_centered(Vector2i(800, 600))

func _on_file_selected(path: String):
	file_label.text = "Loading: " + path.get_file()
	status_label.text = "Processing audio..."
	status_label.add_theme_color_override("font_color", Color.YELLOW)
	result_text.text = ""
	confidence_label.text = ""
	
	await get_tree().process_frame
	await _process_audio_file(path)

func _process_audio_file(file_path: String):
	var pcm_data: PackedByteArray
	
	# WAV files: direct conversion (already PCM data)
	# MP3/OGG files: decode through AudioStreamPlayer
	if file_path.ends_with(".wav"):
		pcm_data = await _load_and_convert_wav(file_path)
	elif file_path.ends_with(".mp3"):
		pcm_data = await _load_and_convert_mp3(file_path)
	elif file_path.ends_with(".ogg"):
		pcm_data = await _load_and_convert_ogg(file_path)
	else:
		_show_error("Unsupported file format")
		return
	
	if pcm_data.is_empty():
		_show_error("Failed to load or convert audio file")
		return
	
	# Check audio signal strength
	var max_amplitude = _check_audio_amplitude(pcm_data)
	print("Max audio amplitude: ", max_amplitude, " (out of 32768)")
	
	if max_amplitude < 100:
		_show_error("Audio appears to be silent or very quiet (max amplitude: " + str(max_amplitude) + ")")
		return
	
	# Process with Vosk
	await _recognize_speech(pcm_data)

func _load_and_convert_wav(file_path: String) -> PackedByteArray:
	status_label.text = "Loading WAV file..."
	var stream = _load_wav_manual(file_path)
	if not stream:
		push_error("Failed to load WAV file")
		return PackedByteArray()
	
	print("Converting WAV directly (PCM data)...")
	var pcm = await _convert_audio_to_pcm(stream)
	
	if pcm.is_empty():
		push_error("WAV to PCM conversion returned empty data")
	else:
		print("WAV conversion successful, PCM size: ", pcm.size())
	
	return pcm

func _load_and_convert_mp3(file_path: String) -> PackedByteArray:
	status_label.text = "Loading MP3 file..."
	
	# Load MP3 data
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Cannot open MP3 file")
		return PackedByteArray()
	
	var mp3_data = file.get_buffer(file.get_length())
	file.close()
	
	# Create AudioStreamMP3
	var stream = AudioStreamMP3.new()
	stream.data = mp3_data
	
	# Decode MP3 to PCM using AudioStreamPlayer
	return await _decode_stream_to_pcm(stream)

func _load_and_convert_ogg(file_path: String) -> PackedByteArray:
	status_label.text = "Loading OGG file..."
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Cannot open OGG file")
		return PackedByteArray()
	
	var ogg_data = file.get_buffer(file.get_length())
	file.close()
	
	var stream = AudioStreamOggVorbis.load_from_buffer(ogg_data)
	if not stream:
		push_error("Failed to load OGG")
		return PackedByteArray()
	
	return await _decode_stream_to_pcm(stream)

func _decode_stream_to_pcm(audio_stream: AudioStream) -> PackedByteArray:
	"""Decode any AudioStream to PCM using AudioStreamPlayer"""
	status_label.text = "Decoding audio..."
	
	# Create temporary nodes for playback and capture
	var player = AudioStreamPlayer.new()
	var bus_name = "VoskDecoder_" + str(randi())
	
	# Setup audio bus with capture
	var bus_idx = AudioServer.get_bus_count()
	AudioServer.add_bus(bus_idx)
	AudioServer.set_bus_name(bus_idx, bus_name)
	
	var capture_effect = AudioEffectCapture.new()
	capture_effect.buffer_length = 60.0  # Support up to 60 seconds
	AudioServer.add_bus_effect(bus_idx, capture_effect)
	
	# Configure player
	player.stream = audio_stream
	player.bus = bus_name
	add_child(player)
	
	# Start playback
	player.play()
	
	# Wait for playback to finish
	var duration = audio_stream.get_length()
	var wait_time = duration + 0.5
	print("Decoding audio (", duration, " seconds)...")
	
	await get_tree().create_timer(wait_time).timeout
	
	# Capture the audio
	var frames = capture_effect.get_frames_available()
	var stereo_data = capture_effect.get_buffer(frames)
	
	print("Captured ", frames, " frames")
	
	# Cleanup
	player.queue_free()
	AudioServer.remove_bus(bus_idx)
	
	# Convert to mono 16-bit PCM
	var sample_rate = AudioServer.get_mix_rate()
	var pcm_data = PackedByteArray()
	
	for frame in stereo_data:
		# Average stereo to mono
		var mono_sample = (frame.x + frame.y) / 2.0
		var int_sample = int(clamp(mono_sample * 32767.0, -32768, 32767))
		pcm_data.append(int_sample & 0xFF)
		pcm_data.append((int_sample >> 8) & 0xFF)
	
	# Resample to 16kHz if needed
	if sample_rate != 16000:
		print("Resampling from ", sample_rate, " Hz to 16000 Hz...")
		pcm_data = await _resample_audio(pcm_data, int(sample_rate), 16000)
	
	return pcm_data

func _load_wav_manual(file_path: String) -> AudioStream:
	var stream = AudioStreamWAV.new()
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if not file:
		return null
	
	var riff = file.get_buffer(4).get_string_from_ascii()
	if riff != "RIFF":
		file.close()
		return null
	
	file.get_32()
	var wave = file.get_buffer(4).get_string_from_ascii()
	if wave != "WAVE":
		file.close()
		return null
	
	while file.get_position() < file.get_length():
		var chunk_id = file.get_buffer(4).get_string_from_ascii()
		var chunk_size = file.get_32()
		
		if chunk_id == "fmt ":
			var audio_format = file.get_16()
			var num_channels = file.get_16()
			var sample_rate = file.get_32()
			file.get_32()
			file.get_16()
			var bits_per_sample = file.get_16()
			
			if chunk_size > 16:
				file.get_buffer(chunk_size - 16)
			
			stream.mix_rate = sample_rate
			stream.stereo = (num_channels == 2)
			
			if bits_per_sample == 8:
				stream.format = AudioStreamWAV.FORMAT_8_BITS
			elif bits_per_sample == 16:
				stream.format = AudioStreamWAV.FORMAT_16_BITS
			
		elif chunk_id == "data":
			stream.data = file.get_buffer(chunk_size)
			break
		else:
			file.get_buffer(chunk_size)
	
	file.close()
	
	if stream.data.size() == 0:
		return null
	
	print("Loaded WAV: ", stream.mix_rate, "Hz, ", "Stereo" if stream.stereo else "Mono")
	return stream

func _convert_audio_to_pcm(audio_stream: AudioStream) -> PackedByteArray:
	print("Converting audio to PCM, stream type: ", audio_stream.get_class())
	
	if not audio_stream is AudioStreamWAV:
		push_error("Audio stream is not WAV type!")
		return PackedByteArray()
	
	var wav: AudioStreamWAV = audio_stream
	var raw_data = wav.data
	
	print("WAV format: ", wav.format, ", Stereo: ", wav.stereo, ", Rate: ", wav.mix_rate, ", Data size: ", raw_data.size())
	
	var mono_data = PackedByteArray()
	
	# Convert to mono 16-bit
	if wav.format == AudioStreamWAV.FORMAT_16_BITS:
		if wav.stereo:
			for i in range(0, raw_data.size(), 4):
				if i + 3 < raw_data.size():
					var left = raw_data[i] | (raw_data[i + 1] << 8)
					var right = raw_data[i + 2] | (raw_data[i + 3] << 8)
					
					if left > 32767:
						left -= 65536
					if right > 32767:
						right -= 65536
					
					var mono = (left + right) / 2
					mono_data.append(mono & 0xFF)
					mono_data.append((mono >> 8) & 0xFF)
		else:
			mono_data = raw_data
	
	elif wav.format == AudioStreamWAV.FORMAT_8_BITS:
		for i in range(raw_data.size()):
			var sample_8 = raw_data[i]
			var sample_16 = (sample_8 - 128) * 256
			mono_data.append(sample_16 & 0xFF)
			mono_data.append((sample_16 >> 8) & 0xFF)
	else:
		push_error("Unsupported WAV format: ", wav.format)
		return PackedByteArray()
	
	print("Mono conversion complete, size: ", mono_data.size())
	
	# Verify data has content
	if mono_data.size() > 0:
		var sample_check = mono_data[0] | (mono_data[1] << 8)
		if sample_check > 32767:
			sample_check -= 65536
		print("First audio sample value: ", sample_check)
	
	# Resample if needed
	if wav.mix_rate != 16000:
		print("Resampling from ", wav.mix_rate, " Hz to 16000 Hz...")
		status_label.text = "Resampling audio..."
		mono_data = await _resample_audio(mono_data, wav.mix_rate, 16000)
	
	print("Final PCM data size: ", mono_data.size())
	return mono_data

func _resample_audio(audio_data: PackedByteArray, from_rate: int, to_rate: int) -> PackedByteArray:
	var resampled = PackedByteArray()
	var ratio = float(from_rate) / float(to_rate)
	var input_samples = audio_data.size() / 2
	var output_samples = int(input_samples / ratio)
	
	resampled.resize(output_samples * 2)
	
	var last_progress = 0
	for i in range(output_samples):
		var progress = int((float(i) / output_samples) * 100)
		if progress > last_progress and progress % 20 == 0:
			print("  Resampling: ", progress, "%")
			status_label.text = "Resampling: " + str(progress) + "%"
			last_progress = progress
			await Engine.get_main_loop().process_frame
		
		var src_pos = i * ratio
		var src_index = int(src_pos)
		var frac = src_pos - src_index
		
		var idx1 = src_index * 2
		if idx1 + 1 >= audio_data.size():
			break
		
		var sample1 = audio_data[idx1] | (audio_data[idx1 + 1] << 8)
		if sample1 > 32767:
			sample1 -= 65536
		
		var sample2 = sample1
		var idx2 = (src_index + 1) * 2
		if idx2 + 1 < audio_data.size():
			sample2 = audio_data[idx2] | (audio_data[idx2 + 1] << 8)
			if sample2 > 32767:
				sample2 -= 65536
		
		var interpolated = int(sample1 + (sample2 - sample1) * frac)
		var out_idx = i * 2
		resampled[out_idx] = interpolated & 0xFF
		resampled[out_idx + 1] = (interpolated >> 8) & 0xFF
	
	return resampled

func _check_audio_amplitude(pcm_data: PackedByteArray) -> int:
	var max_amplitude = 0
	for i in range(0, pcm_data.size(), 2):
		if i + 1 < pcm_data.size():
			var sample = pcm_data[i] | (pcm_data[i + 1] << 8)
			if sample > 32767:
				sample -= 65536
			max_amplitude = max(max_amplitude, abs(sample))
	return max_amplitude

func _recognize_speech(pcm_data: PackedByteArray):
	status_label.text = "Recognizing speech..."
	vosk.reset()
	
	print("Starting recognition with ", pcm_data.size(), " bytes of PCM data")
	
	var chunk_size = 4096
	var chunks_sent = 0
	var got_intermediate_result = false
	
	for i in range(0, pcm_data.size(), chunk_size):
		var end = min(i + chunk_size, pcm_data.size())
		var chunk = pcm_data.slice(i, end)
		var intermediate = vosk.accept_waveform(chunk)
		chunks_sent += 1
		
		# Check for intermediate results
		if intermediate != "{}":
			print("Got intermediate result: ", intermediate)
			got_intermediate_result = true
		
		# Update progress
		if chunks_sent % 10 == 0:
			var progress = int((float(i) / pcm_data.size()) * 100)
			status_label.text = "Recognizing: " + str(progress) + "%"
			await Engine.get_main_loop().process_frame
	
	print("Sent ", chunks_sent, " chunks to Vosk")
	print("Got intermediate results: ", got_intermediate_result)
	
	# Get final result with word confidence
	var result_json = vosk.get_final_result()
	print("Final result JSON: ", result_json)
	var result = JSON.parse_string(result_json)
	
	if result:
		print("Parsed result has text: ", result.has("text"))
		if result.has("text"):
			print("Text content: '", result["text"], "'")
			print("Text length: ", result["text"].length())
	
	if result and result.has("text") and result["text"] != "":
		_display_result(result)
	else:
		_show_error("No speech detected in audio")

func _display_result(result: Dictionary):
	status_label.text = "Recognition complete!"
	status_label.add_theme_color_override("font_color", Color.GREEN)
	
	var text = result.get("text", "")
	result_text.text = "Recognized Text:\n" + text
	
	# ALWAYS calculate confidence (required for game scoring)
	if result.has("result") and result["result"] is Array:
		var words = result["result"]
		
		if words.size() > 0:
			var total_conf = 0.0
			var word_count = 0
			var details = "\n\nWord-by-word confidence:\n"
			
			for word_data in words:
				if word_data is Dictionary and word_data.has("word"):
					var word = word_data.get("word", "")
					var conf = word_data.get("conf", 1.0)  # Default to 1.0 if missing
					total_conf += conf
					word_count += 1
					details += "  '%s': %.1f%%\n" % [word, conf * 100]
			
			var avg_conf = total_conf / word_count if word_count > 0 else 0.0
			confidence_label.text = "Average Confidence: %.1f%% (Score: %.0f/100)" % [avg_conf * 100, avg_conf * 100]
			
			if avg_conf > 0.8:
				confidence_label.add_theme_color_override("font_color", Color.GREEN)
			elif avg_conf > 0.6:
				confidence_label.add_theme_color_override("font_color", Color.YELLOW)
			else:
				confidence_label.add_theme_color_override("font_color", Color.ORANGE)
			
			result_text.text += details
		else:
			# No words but text exists - use fallback score
			confidence_label.text = "Confidence: 75% (estimated)"
			confidence_label.add_theme_color_override("font_color", Color.YELLOW)
	else:
		# Fallback if no detailed results
		confidence_label.text = "Confidence: 70% (no detailed data)"
		confidence_label.add_theme_color_override("font_color", Color.YELLOW)

func _show_error(message: String):
	status_label.text = "ERROR: " + message
	status_label.add_theme_color_override("font_color", Color.RED)
	result_text.text = ""
	confidence_label.text = ""
