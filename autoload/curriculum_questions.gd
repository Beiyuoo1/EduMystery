extends Node

# Curriculum Question Database for Philippine Senior High School
# Organized by subject > quarter > minigame type

# Quarter mapping based on chapter:
# Chapters 1-2: Q1 (First Quarter)
# Chapter 3: Q2 (Second Quarter)
# Chapter 4: Q3 (Third Quarter)
# Chapter 5: Q4 (Fourth Quarter)

func _chapter_to_quarter(chapter: int) -> String:
	match chapter:
		1, 2:
			return "Q1"
		3:
			return "Q2"
		4:
			return "Q3"
		_:
			return "Q4"

func get_config(minigame_type: String) -> Dictionary:
	var subject = Dialogic.VAR.selected_subject
	var chapter = Dialogic.VAR.current_chapter
	var quarter = _chapter_to_quarter(chapter)

	if not questions.has(subject):
		push_warning("Unknown subject: " + subject)
		return {}

	if not questions[subject].has(quarter):
		push_warning("No questions for quarter: " + quarter)
		return {}

	if not questions[subject][quarter].has(minigame_type):
		push_warning("No " + minigame_type + " for " + subject + "/" + quarter)
		return {}

	return questions[subject][quarter][minigame_type]


# =============================================================================
# QUESTION DATABASE
# =============================================================================

var questions = {
	# =========================================================================
	# MATHEMATICS - Philippine SHS General Mathematics Curriculum
	# Grade 12 - General Mathematics
	# =========================================================================
	"math": {
		# Q1: Functions, Operations, Inverse Functions (Chapters 1-2)
		"Q1": {
			"pacman": {
				"questions": [
					# Function evaluation
					{"question": "If f(x) = 2x + 3, what is f(4)?", "correct": "11", "wrong": ["8", "9", "14"]},
					{"question": "If f(x) = x^2, what is f(3)?", "correct": "9", "wrong": ["6", "3", "12"]},
					{"question": "If f(x) = x - 7, what is f(10)?", "correct": "3", "wrong": ["7", "17", "-3"]},
					{"question": "If g(x) = 3x, what is g(5)?", "correct": "15", "wrong": ["8", "35", "53"]},
					# Function concepts
					{"question": "What test determines if a graph is a function?", "correct": "Vertical line", "wrong": ["Horizontal line", "Diagonal line", "Slope test"]},
					{"question": "The domain is the set of all?", "correct": "Inputs", "wrong": ["Outputs", "Functions", "Ranges"]},
					{"question": "The range is the set of all?", "correct": "Outputs", "wrong": ["Inputs", "Domains", "Variables"]},
					{"question": "f(x) = 1/x is undefined when x = ?", "correct": "0", "wrong": ["1", "-1", "2"]}
				]
			},
			"runner": {
				"questions": [
					# Inverse functions
					{"question": "What is the inverse of f(x) = x + 5?", "correct": "x - 5", "wrong": ["x + 5", "x / 5", "5x"]},
					{"question": "What is the inverse of f(x) = 2x?", "correct": "x / 2", "wrong": ["2x", "x - 2", "x + 2"]},
					{"question": "What is the inverse of f(x) = x - 3?", "correct": "x + 3", "wrong": ["x - 3", "3x", "x / 3"]},
					# Function operations
					{"question": "If f(x)=2x and g(x)=3x, what is (f+g)(x)?", "correct": "5x", "wrong": ["6x", "x", "6x^2"]},
					{"question": "If f(x)=x and g(x)=2, what is (f*g)(x)?", "correct": "2x", "wrong": ["x+2", "x-2", "x/2"]},
					# One-to-one functions
					{"question": "A one-to-one function passes which test?", "correct": "Horizontal line", "wrong": ["Vertical line", "Slope test", "Zero test"]},
					{"question": "The notation for inverse of f is?", "correct": "f^-1", "wrong": ["1/f", "-f", "f*"]},
					{"question": "f(f^-1(x)) always equals?", "correct": "x", "wrong": ["0", "1", "f(x)"]}
				],
				"answers_needed": 5
			},
			"maze": {
				"questions": [
					{"question": "What is the notation for an inverse function?", "correct": "f^-1(x)", "wrong": ["f(x)^-1", "1/f(x)", "-f(x)"]},
					{"question": "Piecewise functions are defined by?", "correct": "Multiple rules", "wrong": ["One rule", "No rules", "Equations"]},
					{"question": "What test checks if an inverse is a function?", "correct": "Horizontal line", "wrong": ["Vertical line", "Diagonal line", "No test"]},
					{"question": "The domain of f^-1 is the ___ of f?", "correct": "Range", "wrong": ["Domain", "Function", "Inverse"]},
					{"question": "A relation where each input has one output is a?", "correct": "Function", "wrong": ["Variable", "Constant", "Set"]}
				]
			},
			"platformer": {
				"questions": [
					{"question": "What is (f * g)(x) if f(x)=2 and g(x)=x?", "correct": "2x", "wrong": ["x+2", "x-2", "x/2"]},
					{"question": "A function maps each input to how many outputs?", "correct": "Exactly one", "wrong": ["Two", "Many", "None"]},
					{"question": "What is 4! (factorial)?", "correct": "24", "wrong": ["4", "16", "8"]},
					{"question": "Evaluate: |−9|", "correct": "9", "wrong": ["-9", "0", "1"]},
					{"question": "If f(x) = x + 1, what is f(0)?", "correct": "1", "wrong": ["0", "-1", "2"]}
				],
				"answers_needed": 3
			},
			"fillinblank": {
				"sentence_parts": ["A function assigns each ", " to exactly one ", "."],
				"answers": ["input", "output"],
				"choices": ["input", "output", "domain", "range", "variable", "constant", "equation", "value"]
			},
			"math": {
				"questions": [
					{"question": "Evaluate f(x) = 3x - 5 when x = 4", "correct": "7", "wrong": ["12", "2", "17"]},
					{"question": "If f(x) = x² + 1, what is f(3)?", "correct": "10", "wrong": ["9", "8", "6"]},
					{"question": "What is the domain of f(x) = 1/(x-2)?", "correct": "x ≠ 2", "wrong": ["x > 2", "x < 2", "All reals"]},
					{"question": "If f(x) = 2x and g(x) = x+3, find (f∘g)(2)", "correct": "10", "wrong": ["7", "8", "12"]},
					{"question": "What is the inverse of f(x) = 2x + 4?", "correct": "(x-4)/2", "wrong": ["2x-4", "x/2+4", "(x+4)/2"]}
				],
				"time_per_question": 20.0
			}
		},

		# Q2: Exponential & Logarithmic Functions (Chapter 3)
		"Q2": {
			"pacman": {
				"questions": [
					# Logarithm basics
					{"question": "What is log base 10 of 100?", "correct": "2", "wrong": ["10", "100", "1"]},
					{"question": "What is log base 10 of 1000?", "correct": "3", "wrong": ["10", "100", "30"]},
					{"question": "What is log base 2 of 8?", "correct": "3", "wrong": ["2", "4", "8"]},
					{"question": "What is log base 2 of 16?", "correct": "4", "wrong": ["2", "8", "16"]},
					# Exponential basics
					{"question": "2^4 equals?", "correct": "16", "wrong": ["8", "6", "32"]},
					{"question": "3^3 equals?", "correct": "27", "wrong": ["9", "6", "81"]},
					{"question": "5^2 equals?", "correct": "25", "wrong": ["10", "52", "32"]},
					{"question": "Any number raised to 0 equals?", "correct": "1", "wrong": ["0", "Undefined", "Itself"]}
				]
			},
			"runner": {
				"questions": [
					# Log properties
					{"question": "log(ab) equals log(a) + ?", "correct": "log(b)", "wrong": ["log(a)", "ab", "a+b"]},
					{"question": "log(a/b) equals log(a) - ?", "correct": "log(b)", "wrong": ["log(a)", "a-b", "b/a"]},
					{"question": "log(a^n) equals?", "correct": "n log(a)", "wrong": ["a log(n)", "log(n)", "a^n"]},
					{"question": "log(1) equals?", "correct": "0", "wrong": ["1", "10", "undefined"]},
					# Exponential properties
					{"question": "a^m * a^n equals?", "correct": "a^(m+n)", "wrong": ["a^(mn)", "a^(m-n)", "(a*a)^mn"]},
					{"question": "a^m / a^n equals?", "correct": "a^(m-n)", "wrong": ["a^(m+n)", "a^(mn)", "a^(m/n)"]},
					# Applications
					{"question": "Compound interest grows how?", "correct": "Exponentially", "wrong": ["Linearly", "Constantly", "Slowly"]},
					{"question": "What is e approximately equal to?", "correct": "2.718", "wrong": ["3.14", "1.618", "2.5"]}
				],
				"answers_needed": 5
			},
			"maze": {
				"questions": [
					{"question": "Exponential decay has a base between?", "correct": "0 and 1", "wrong": ["1 and 2", "-1 and 0", "2 and 3"]},
					{"question": "Half-life problems use which function?", "correct": "Exponential", "wrong": ["Linear", "Quadratic", "Constant"]},
					{"question": "What is the inverse of y = 10^x?", "correct": "y = log x", "wrong": ["y = 10x", "y = x^10", "y = x/10"]},
					{"question": "The base of natural logarithm ln is?", "correct": "e", "wrong": ["10", "2", "pi"]},
					{"question": "Exponential growth has base greater than?", "correct": "1", "wrong": ["0", "-1", "0.5"]}
				]
			},
			"platformer": {
				"questions": [
					{"question": "5^0 equals?", "correct": "1", "wrong": ["0", "5", "50"]},
					{"question": "10^1 equals?", "correct": "10", "wrong": ["1", "100", "0"]},
					{"question": "2^5 equals?", "correct": "32", "wrong": ["10", "25", "64"]},
					{"question": "4^2 equals?", "correct": "16", "wrong": ["8", "6", "42"]},
					{"question": "log base 10 of 10 equals?", "correct": "1", "wrong": ["0", "10", "100"]}
				],
				"answers_needed": 3
			},
			"fillinblank": {
				"sentence_parts": ["The inverse of an ", " function is a ", " function."],
				"answers": ["exponential", "logarithmic"],
				"choices": ["exponential", "logarithmic", "linear", "quadratic", "polynomial", "rational", "constant", "inverse"]
			},
			"math": {
				"questions": [
					{"question": "Simplify: 2³ × 2⁴", "correct": "128", "wrong": ["64", "256", "32"]},
					{"question": "What is log₁₀(1000)?", "correct": "3", "wrong": ["2", "4", "10"]},
					{"question": "Solve: 2ˣ = 16", "correct": "4", "wrong": ["3", "5", "8"]},
					{"question": "What is ln(e)?", "correct": "1", "wrong": ["0", "e", "2.718"]},
					{"question": "log(ab) equals?", "correct": "log a + log b", "wrong": ["log a × log b", "log a - log b", "(log a)(log b)"]}
				],
				"time_per_question": 20.0
			}
		},

		# Q3: Trigonometry - Unit Circle, Identities (Chapter 4)
		"Q3": {
			"pacman": {
				"questions": [
					# Basic trig values
					{"question": "sin(90°) equals?", "correct": "1", "wrong": ["0", "-1", "0.5"]},
					{"question": "cos(0°) equals?", "correct": "1", "wrong": ["0", "-1", "0.5"]},
					{"question": "sin(0°) equals?", "correct": "0", "wrong": ["1", "-1", "0.5"]},
					{"question": "cos(90°) equals?", "correct": "0", "wrong": ["1", "-1", "0.5"]},
					{"question": "tan(45°) equals?", "correct": "1", "wrong": ["0", "2", "0.5"]},
					{"question": "sin(30°) equals?", "correct": "0.5", "wrong": ["1", "0", "0.866"]},
					{"question": "cos(60°) equals?", "correct": "0.5", "wrong": ["1", "0", "0.866"]},
					{"question": "sin(180°) equals?", "correct": "0", "wrong": ["1", "-1", "0.5"]}
				]
			},
			"runner": {
				"questions": [
					# Conversions and identities
					{"question": "Pi radians equals how many degrees?", "correct": "180", "wrong": ["360", "90", "270"]},
					{"question": "How many radians in 90 degrees?", "correct": "pi/2", "wrong": ["pi", "2pi", "pi/4"]},
					{"question": "sin^2(x) + cos^2(x) = ?", "correct": "1", "wrong": ["0", "2", "sin(2x)"]},
					{"question": "The period of sin(x) is?", "correct": "2 pi", "wrong": ["pi", "pi/2", "4 pi"]},
					{"question": "What is the amplitude of y = 3sin(x)?", "correct": "3", "wrong": ["1", "6", "1/3"]},
					# Reciprocal functions
					{"question": "csc is the reciprocal of?", "correct": "sin", "wrong": ["cos", "tan", "sec"]},
					{"question": "sec is the reciprocal of?", "correct": "cos", "wrong": ["sin", "tan", "cot"]},
					{"question": "cot is the reciprocal of?", "correct": "tan", "wrong": ["sin", "cos", "sec"]}
				],
				"answers_needed": 5
			},
			"maze": {
				"questions": [
					{"question": "In Quadrant II, sin is positive and cos is?", "correct": "Negative", "wrong": ["Positive", "Zero", "Undefined"]},
					{"question": "In Quadrant III, both sin and cos are?", "correct": "Negative", "wrong": ["Positive", "Zero", "One positive"]},
					{"question": "The unit circle has radius?", "correct": "1", "wrong": ["2", "pi", "0"]},
					{"question": "tan = sin divided by?", "correct": "cos", "wrong": ["tan", "sin", "sec"]},
					{"question": "cot = cos divided by?", "correct": "sin", "wrong": ["tan", "cos", "sec"]}
				]
			},
			"platformer": {
				"questions": [
					{"question": "How many degrees in a full circle?", "correct": "360", "wrong": ["180", "90", "270"]},
					{"question": "How many radians in a full circle?", "correct": "2 pi", "wrong": ["pi", "4 pi", "pi/2"]},
					{"question": "cos(180°) equals?", "correct": "-1", "wrong": ["1", "0", "0.5"]},
					{"question": "What angle has sin = cos?", "correct": "45 degrees", "wrong": ["30 degrees", "60 degrees", "90 degrees"]},
					{"question": "sin(270°) equals?", "correct": "-1", "wrong": ["1", "0", "0.5"]}
				],
				"answers_needed": 3
			},
			"fillinblank": {
				"sentence_parts": ["The ", " function relates an angle to the ratio of opposite over ", "."],
				"answers": ["sine", "hypotenuse"],
				"choices": ["sine", "cosine", "tangent", "hypotenuse", "adjacent", "opposite", "angle", "ratio"]
			},
			"math": {
				"questions": [
					{"question": "What is sin(30°)?", "correct": "1/2", "wrong": ["√3/2", "√2/2", "1"]},
					{"question": "What is cos(60°)?", "correct": "1/2", "wrong": ["√3/2", "√2/2", "0"]},
					{"question": "What is tan(45°)?", "correct": "1", "wrong": ["0", "√2", "√3"]},
					{"question": "sin²θ + cos²θ equals?", "correct": "1", "wrong": ["0", "2", "sin 2θ"]},
					{"question": "What is the period of sin(x)?", "correct": "2π", "wrong": ["π", "π/2", "4π"]}
				],
				"time_per_question": 20.0
			}
		},

		# Q4: Statistics and Probability (Chapter 5)
		"Q4": {
			"pacman": {
				"questions": [
					# Central tendency
					{"question": "The mean of 2, 4, 6 is?", "correct": "4", "wrong": ["2", "6", "12"]},
					{"question": "The mean of 10, 20, 30 is?", "correct": "20", "wrong": ["10", "30", "60"]},
					{"question": "The median of 1, 3, 5 is?", "correct": "3", "wrong": ["1", "5", "9"]},
					{"question": "The mode of 2, 2, 3, 4 is?", "correct": "2", "wrong": ["3", "4", "2.75"]},
					# Probability basics
					{"question": "Probability ranges from?", "correct": "0 to 1", "wrong": ["0 to 100", "-1 to 1", "1 to 10"]},
					{"question": "P(heads) for fair coin is?", "correct": "0.5", "wrong": ["0.25", "1", "0"]},
					{"question": "Probability of impossible event?", "correct": "0", "wrong": ["1", "0.5", "-1"]},
					{"question": "Probability of certain event?", "correct": "1", "wrong": ["0", "0.5", "100"]}
				]
			},
			"runner": {
				"questions": [
					# Variability measures
					{"question": "Standard deviation measures?", "correct": "Spread", "wrong": ["Center", "Mode", "Median"]},
					{"question": "Variance is standard deviation?", "correct": "Squared", "wrong": ["Halved", "Doubled", "Cubed"]},
					{"question": "Range = Maximum minus?", "correct": "Minimum", "wrong": ["Mean", "Mode", "Median"]},
					# Probability rules
					{"question": "P(A and B) for independent events = ?", "correct": "P(A) x P(B)", "wrong": ["P(A) + P(B)", "P(A) - P(B)", "P(A)/P(B)"]},
					{"question": "P(A or B) for mutually exclusive = ?", "correct": "P(A) + P(B)", "wrong": ["P(A) x P(B)", "P(A) - P(B)", "P(A)/P(B)"]},
					{"question": "P(not A) = 1 minus?", "correct": "P(A)", "wrong": ["P(B)", "0", "1"]},
					{"question": "The sum of all probabilities equals?", "correct": "1", "wrong": ["0", "100", "0.5"]},
					# Distribution
					{"question": "The normal curve is shaped like?", "correct": "Bell", "wrong": ["Square", "Triangle", "Line"]}
				],
				"answers_needed": 5
			},
			"maze": {
				"questions": [
					{"question": "In a normal distribution, mean = median = ?", "correct": "Mode", "wrong": ["Range", "Variance", "Sum"]},
					{"question": "nCr is used for?", "correct": "Combinations", "wrong": ["Permutations", "Probability", "Mean"]},
					{"question": "nPr is used for?", "correct": "Permutations", "wrong": ["Combinations", "Variance", "Mode"]},
					{"question": "5! (factorial) equals?", "correct": "120", "wrong": ["25", "20", "60"]},
					{"question": "4! (factorial) equals?", "correct": "24", "wrong": ["4", "16", "8"]}
				]
			},
			"platformer": {
				"questions": [
					{"question": "Mean is also called?", "correct": "Average", "wrong": ["Middle", "Most common", "Range"]},
					{"question": "Median is the ___ value?", "correct": "Middle", "wrong": ["First", "Last", "Largest"]},
					{"question": "Mode is the most ___ value?", "correct": "Frequent", "wrong": ["Average", "Middle", "Large"]},
					{"question": "3! equals?", "correct": "6", "wrong": ["3", "9", "27"]},
					{"question": "Rolling a 6 on fair die: P = ?", "correct": "1/6", "wrong": ["1/2", "1/3", "6"]}
				],
				"answers_needed": 3
			},
			"fillinblank": {
				"sentence_parts": ["The ", " is the sum of values divided by the ", " of values."],
				"answers": ["mean", "count"],
				"choices": ["mean", "median", "mode", "count", "range", "sum", "total", "number"]
			},
			"math": {
				"questions": [
					{"question": "The mean of 2, 4, 6, 8 is?", "correct": "5", "wrong": ["4", "6", "20"]},
					{"question": "The median of 1, 3, 5, 7, 9 is?", "correct": "5", "wrong": ["3", "7", "25"]},
					{"question": "P(A) + P(not A) equals?", "correct": "1", "wrong": ["0", "2", "P(A)²"]},
					{"question": "Probability of rolling 6 on a die?", "correct": "1/6", "wrong": ["1/2", "1/3", "6"]},
					{"question": "Standard deviation measures?", "correct": "Spread", "wrong": ["Center", "Mode", "Range"]}
				],
				"time_per_question": 20.0
			}
		}
	},

	# =========================================================================
	# SCIENCE - Philippine SHS Physical Science Curriculum (Physics Focus)
	# =========================================================================
	"science": {
		# Q1: Motion and Forces (Kinematics, Newton's Laws)
		"Q1": {
			"pacman": {
				"questions": [
					{
						"question": "Speed is distance divided by?",
						"correct": "Time",
						"wrong": ["Mass", "Force", "Velocity"]
					},
					{
						"question": "The SI unit of force is?",
						"correct": "Newton",
						"wrong": ["Joule", "Watt", "Meter"]
					},
					{
						"question": "Acceleration is the rate of change of?",
						"correct": "Velocity",
						"wrong": ["Distance", "Speed", "Position"]
					},
					{
						"question": "An object at rest stays at rest unless acted upon by?",
						"correct": "Force",
						"wrong": ["Speed", "Time", "Mass"]
					},
					{
						"question": "Mass times acceleration equals?",
						"correct": "Force",
						"wrong": ["Velocity", "Power", "Energy"]
					},
					{
						"question": "Free fall acceleration on Earth is?",
						"correct": "10 m/s²",
						"wrong": ["5 m/s²", "20 m/s²", "1 m/s²"]
					},
					{
						"question": "Velocity includes speed and?",
						"correct": "Direction",
						"wrong": ["Mass", "Time", "Force"]
					},
					{
						"question": "Newton's first law is also called law of?",
						"correct": "Inertia",
						"wrong": ["Motion", "Gravity", "Action"]
					}
				]
			},
			"runner": {
				"questions": [
					{
						"question": "If a car accelerates from 0 to 20 m/s in 5s, acceleration is?",
						"correct": "4 m/s²",
						"wrong": ["5 m/s²", "20 m/s²", "2 m/s²"]
					},
					{
						"question": "A 5 kg object accelerates at 2 m/s². Force applied?",
						"correct": "10 N",
						"wrong": ["5 N", "7 N", "20 N"]
					},
					{
						"question": "Friction always opposes?",
						"correct": "Motion",
						"wrong": ["Gravity", "Time", "Mass"]
					},
					{
						"question": "Action and reaction forces are?",
						"correct": "Equal and opposite",
						"wrong": ["Same direction", "Unequal", "Zero"]
					},
					{
						"question": "Terminal velocity occurs when air resistance equals?",
						"correct": "Weight",
						"wrong": ["Mass", "Speed", "Time"]
					},
					{
						"question": "Momentum is mass times?",
						"correct": "Velocity",
						"wrong": ["Acceleration", "Force", "Time"]
					}
				],
				"answers_needed": 4
			},
			"maze": {
				"questions": [
					{
						"question": "Newton's 2nd Law formula is?",
						"correct": "F = ma",
						"wrong": ["F = mv", "F = ma²", "F = m/a"]
					},
					{
						"question": "Velocity formula is?",
						"correct": "v = d/t",
						"wrong": ["v = dt", "v = t/d", "v = d²/t"]
					},
					{
						"question": "Acceleration formula is?",
						"correct": "a = Δv/t",
						"wrong": ["a = vt", "a = v/d", "a = t/v"]
					},
					{
						"question": "Which law explains rocket propulsion?",
						"correct": "3rd Law",
						"wrong": ["1st Law", "2nd Law", "Gravity"]
					},
					{
						"question": "Momentum is conserved in?",
						"correct": "Collisions",
						"wrong": ["Friction", "Gravity", "Acceleration"]
					}
				]
			},
			"platformer": {
				"questions": [
					{
						"question": "Constant velocity means acceleration is?",
						"correct": "Zero",
						"wrong": ["Positive", "Negative", "Infinite"]
					},
					{
						"question": "Greater mass means greater?",
						"correct": "Inertia",
						"wrong": ["Speed", "Velocity", "Time"]
					},
					{
						"question": "Objects in free fall have constant?",
						"correct": "Acceleration",
						"wrong": ["Velocity", "Position", "Mass"]
					},
					{
						"question": "Net force of zero means?",
						"correct": "Equilibrium",
						"wrong": ["Acceleration", "Motion", "Friction"]
					}
				],
				"answers_needed": 3
			},
			"fillinblank": {
				"sentence_parts": [
					"Newton's second law states that ", " equals mass times ", "."
				],
				"answers": ["force", "acceleration"],
				"choices": [
					"force", "velocity", "acceleration", "speed",
					"momentum", "energy", "power", "mass"
				]
			},
			"math": {
				"questions": [
					{
						"question": "A 5 kg object accelerates at 2 m/s². What is the force?",
						"correct": "10 N",
						"wrong": ["5 N", "7 N", "20 N"]
					},
					{
						"question": "If velocity changes from 0 to 20 m/s in 5s, what is acceleration?",
						"correct": "4 m/s²",
						"wrong": ["5 m/s²", "20 m/s²", "2 m/s²"]
					},
					{
						"question": "Calculate velocity: distance = 100m, time = 20s",
						"correct": "5 m/s",
						"wrong": ["2 m/s", "10 m/s", "20 m/s"]
					},
					{
						"question": "A 10 kg object accelerates at 3 m/s². Force?",
						"correct": "30 N",
						"wrong": ["10 N", "13 N", "3 N"]
					},
					{
						"question": "Momentum = mass × velocity. If m=4kg, v=5m/s, momentum?",
						"correct": "20 kg·m/s",
						"wrong": ["9 kg·m/s", "1 kg·m/s", "25 kg·m/s"]
					}
				],
				"time_per_question": 20.0
			}
		},

		# Q2: Work, Energy, and Power
		"Q2": {
			"pacman": {
				"questions": [
					{
						"question": "Work is force times?",
						"correct": "Distance",
						"wrong": ["Time", "Mass", "Velocity"]
					},
					{
						"question": "The SI unit of work is?",
						"correct": "Joule",
						"wrong": ["Newton", "Watt", "Meter"]
					},
					{
						"question": "The SI unit of power is?",
						"correct": "Watt",
						"wrong": ["Joule", "Newton", "Meter"]
					},
					{
						"question": "Energy stored due to position is?",
						"correct": "Potential",
						"wrong": ["Kinetic", "Thermal", "Chemical"]
					},
					{
						"question": "Energy of motion is?",
						"correct": "Kinetic",
						"wrong": ["Potential", "Thermal", "Chemical"]
					},
					{
						"question": "50N force pushes box 6m. Work done?",
						"correct": "300 J",
						"wrong": ["250 J", "350 J", "200 J"]
					},
					{
						"question": "Machine does 600J work in 5s. Power?",
						"correct": "120 W",
						"wrong": ["100 W", "150 W", "80 W"]
					},
					{
						"question": "2 kg object lifted 8m (g=10). Potential energy?",
						"correct": "160 J",
						"wrong": ["140 J", "180 J", "120 J"]
					}
				]
			},
			"runner": {
				"questions": [
					{
						"question": "Energy cannot be created or destroyed, only?",
						"correct": "Transformed",
						"wrong": ["Lost", "Gained", "Stopped"]
					},
					{
						"question": "A 3 kg object moves at 4 m/s. Kinetic energy?",
						"correct": "24 J",
						"wrong": ["12 J", "48 J", "16 J"]
					},
					{
						"question": "Spring k=200 N/m stretched 0.05m. Force?",
						"correct": "10 N",
						"wrong": ["8 N", "12 N", "15 N"]
					},
					{
						"question": "Efficiency is output energy divided by?",
						"correct": "Input energy",
						"wrong": ["Time", "Power", "Force"]
					},
					{
						"question": "Friction converts mechanical energy to?",
						"correct": "Heat",
						"wrong": ["Light", "Sound", "Potential"]
					},
					{
						"question": "Power is work divided by?",
						"correct": "Time",
						"wrong": ["Force", "Distance", "Mass"]
					}
				],
				"answers_needed": 4
			},
			"maze": {
				"questions": [
					{
						"question": "Work formula is?",
						"correct": "W = Fd",
						"wrong": ["W = Ft", "W = F/d", "W = mv"]
					},
					{
						"question": "Power formula is?",
						"correct": "P = W/t",
						"wrong": ["P = Wt", "P = F/t", "P = mv"]
					},
					{
						"question": "Kinetic energy formula is?",
						"correct": "KE = ½mv²",
						"wrong": ["KE = mv", "KE = mv²", "KE = ½m²v"]
					},
					{
						"question": "Gravitational PE formula is?",
						"correct": "PE = mgh",
						"wrong": ["PE = mgh²", "PE = mg", "PE = ½mgh"]
					},
					{
						"question": "The law of conservation of energy states energy is?",
						"correct": "Constant",
						"wrong": ["Increasing", "Decreasing", "Zero"]
					}
				]
			},
			"platformer": {
				"questions": [
					{
						"question": "Spring force is proportional to?",
						"correct": "Stretch",
						"wrong": ["Mass", "Time", "Speed"]
					},
					{
						"question": "Higher height means higher stored?",
						"correct": "PE",
						"wrong": ["KE", "Momentum", "Velocity"]
					},
					{
						"question": "Doubling speed increases KE by factor of?",
						"correct": "Four",
						"wrong": ["Two", "Three", "Eight"]
					},
					{
						"question": "At the highest point, a thrown ball has maximum?",
						"correct": "PE",
						"wrong": ["KE", "Speed", "Momentum"]
					}
				],
				"answers_needed": 3
			},
			"fillinblank": {
				"sentence_parts": [
					"The law of conservation of ", " states that energy cannot be created or ", "."
				],
				"answers": ["energy", "destroyed"],
				"choices": [
					"energy", "power", "destroyed", "transformed",
					"mass", "force", "created", "lost"
				]
			},
			"math": {
				"questions": [
					{
						"question": "Object lifted 5m with 20N force. Work done?",
						"correct": "100 J",
						"wrong": ["25 J", "120 J", "80 J"]
					},
					{
						"question": "4 kg object moves at 5 m/s. Kinetic energy?",
						"correct": "50 J",
						"wrong": ["20 J", "100 J", "25 J"]
					},
					{
						"question": "Machine does 600J work in 5s. Power?",
						"correct": "120 W",
						"wrong": ["100 W", "150 W", "80 W"]
					},
					{
						"question": "2 kg object lifted 8m (g=10). Potential energy?",
						"correct": "160 J",
						"wrong": ["140 J", "180 J", "120 J"]
					},
					{
						"question": "5 kg object at 6 m/s. KE?",
						"correct": "90 J",
						"wrong": ["30 J", "180 J", "60 J"]
					}
				],
				"time_per_question": 20.0
			}
		},

		# Q3: Physics - Electricity, Magnetism, Waves
		"Q3": {
			"pacman": {
				"questions": [
					{
						"question": "4Ω and 6Ω resistors in series. Equivalent resistance?",
						"correct": "10 Ω",
						"wrong": ["8 Ω", "12 Ω", "5 Ω"]
					},
					{
						"question": "Wave frequency 5Hz, wavelength 3m. Speed?",
						"correct": "15 m/s",
						"wrong": ["12 m/s", "18 m/s", "10 m/s"]
					},
					{
						"question": "Which shows particle nature of light?",
						"correct": "Photoelectric effect",
						"wrong": ["Interference", "Refraction", "Diffraction"]
					},
					{
						"question": "Device uses 10A current at 24V. Power?",
						"correct": "240 W",
						"wrong": ["200 W", "280 W", "180 W"]
					},
					{
						"question": "Charge 12C passes in 3 seconds. Current?",
						"correct": "4 A",
						"wrong": ["3 A", "5 A", "6 A"]
					},
					{
						"question": "Device has V=12V and I=2A. Power?",
						"correct": "24 W",
						"wrong": ["20 W", "28 W", "18 W"]
					},
					{
						"question": "Wave frequency 12Hz, wavelength 2.5m. Speed?",
						"correct": "30 m/s",
						"wrong": ["25 m/s", "35 m/s", "20 m/s"]
					},
					{
						"question": "Charge q=2C moves at 3 m/s perpendicular to 0.5T field. Force?",
						"correct": "3 N",
						"wrong": ["2 N", "4 N", "5 N"]
					}
				]
			},
			"runner": {
				"questions": [
					{
						"question": "Sound source moves toward observer. Observed frequency?",
						"correct": "Higher",
						"wrong": ["Lower", "Same", "Zero"]
					},
					{
						"question": "Water flows faster in pipe. Pressure becomes?",
						"correct": "Decreases",
						"wrong": ["Increases", "Same", "Zero"]
					},
					{
						"question": "Particle momentum increases. Wavelength?",
						"correct": "Decreases",
						"wrong": ["Increases", "Same", "Zero"]
					},
					{
						"question": "In series, resistors add so total resistance?",
						"correct": "Increases",
						"wrong": ["Decreases", "Same", "Zero"]
					},
					{
						"question": "Light transfers energy in packets called?",
						"correct": "Photons",
						"wrong": ["Waves", "Particles", "Rays"]
					},
					{
						"question": "Electric power is energy per?",
						"correct": "Second",
						"wrong": ["Minute", "Hour", "Meter"]
					}
				],
				"answers_needed": 4
			},
			"maze": {
				"questions": [
					{
						"question": "Ohm's Law formula is?",
						"correct": "V = IR",
						"wrong": ["V = I/R", "V = R/I", "V = I²R"]
					},
					{
						"question": "Electric power formula is?",
						"correct": "P = VI",
						"wrong": ["P = V/I", "P = I/V", "P = VR"]
					},
					{
						"question": "Wave speed formula is?",
						"correct": "v = fλ",
						"wrong": ["v = f/λ", "v = λ/f", "v = f²λ"]
					},
					{
						"question": "Current formula is?",
						"correct": "I = Q/t",
						"wrong": ["I = Qt", "I = t/Q", "I = Q²/t"]
					},
					{
						"question": "Magnetic force formula is?",
						"correct": "F = qvB",
						"wrong": ["F = qv/B", "F = qB/v", "F = q²vB"]
					}
				]
			},
			"platformer": {
				"questions": [
					{
						"question": "Maximum magnetic force occurs when motion is?",
						"correct": "Perpendicular",
						"wrong": ["Parallel", "Diagonal", "Random"]
					},
					{
						"question": "Moving toward observer: waves compress and frequency?",
						"correct": "Increases",
						"wrong": ["Decreases", "Same", "Zero"]
					},
					{
						"question": "Faster fluid speed means pressure?",
						"correct": "Decreases",
						"wrong": ["Increases", "Same", "Zero"]
					},
					{
						"question": "Current is charge flow per?",
						"correct": "Second",
						"wrong": ["Minute", "Meter", "Volt"]
					}
				],
				"answers_needed": 3
			},
			"fillinblank": {
				"sentence_parts": [
					"Wave ", " depends on frequency times ", "."
				],
				"answers": ["speed", "wavelength"],
				"choices": [
					"speed", "frequency", "wavelength", "amplitude",
					"period", "velocity", "distance", "time"
				]
			},
			"math": {
				"questions": [
					{
						"question": "4Ω and 6Ω resistors in series. Equivalent resistance?",
						"correct": "10 Ω",
						"wrong": ["8 Ω", "12 Ω", "5 Ω"]
					},
					{
						"question": "Wave frequency 5Hz, wavelength 3m. Speed?",
						"correct": "15 m/s",
						"wrong": ["12 m/s", "18 m/s", "10 m/s"]
					},
					{
						"question": "Device uses 10A current at 24V. Power?",
						"correct": "240 W",
						"wrong": ["200 W", "280 W", "180 W"]
					},
					{
						"question": "Charge 12C passes in 3 seconds. Current?",
						"correct": "4 A",
						"wrong": ["3 A", "5 A", "6 A"]
					},
					{
						"question": "Charge q=2C moves at 3 m/s perpendicular to 0.5T field. Force?",
						"correct": "3 N",
						"wrong": ["2 N", "4 N", "5 N"]
					}
				],
				"time_per_question": 20.0
			}
		},

		# Q4: Waves, Light, and Modern Physics
		"Q4": {
			"pacman": {
				"questions": [
					{
						"question": "Sound is what type of wave?",
						"correct": "Longitudinal",
						"wrong": ["Transverse", "Circular", "Standing"]
					},
					{
						"question": "Light is what type of wave?",
						"correct": "Transverse",
						"wrong": ["Longitudinal", "Circular", "Static"]
					},
					{
						"question": "The speed of light is approximately?",
						"correct": "3×10⁸ m/s",
						"wrong": ["3×10⁶ m/s", "3×10⁴ m/s", "300 m/s"]
					},
					{
						"question": "The bending of light is called?",
						"correct": "Refraction",
						"wrong": ["Reflection", "Diffraction", "Dispersion"]
					},
					{
						"question": "Red light has the longest?",
						"correct": "Wavelength",
						"wrong": ["Frequency", "Energy", "Speed"]
					},
					{
						"question": "Violet light has the highest?",
						"correct": "Frequency",
						"wrong": ["Wavelength", "Speed", "Amplitude"]
					},
					{
						"question": "Wave frequency 4Hz, wavelength 2m. Speed?",
						"correct": "8 m/s",
						"wrong": ["6 m/s", "2 m/s", "16 m/s"]
					},
					{
						"question": "Photons are packets of?",
						"correct": "Light energy",
						"wrong": ["Sound", "Matter", "Electricity"]
					}
				]
			},
			"runner": {
				"questions": [
					{
						"question": "Higher frequency means higher?",
						"correct": "Energy",
						"wrong": ["Wavelength", "Speed", "Amplitude"]
					},
					{
						"question": "When light enters glass, it?",
						"correct": "Slows down",
						"wrong": ["Speeds up", "Stops", "Stays same"]
					},
					{
						"question": "The photoelectric effect shows light acts as?",
						"correct": "Particles",
						"wrong": ["Waves only", "Matter", "Sound"]
					},
					{
						"question": "Einstein explained photoelectric effect using?",
						"correct": "Photons",
						"wrong": ["Atoms", "Protons", "Electrons only"]
					},
					{
						"question": "Double-slit experiment shows light acts as?",
						"correct": "Waves",
						"wrong": ["Particles only", "Matter", "Sound"]
					},
					{
						"question": "Constructive interference increases?",
						"correct": "Amplitude",
						"wrong": ["Frequency", "Wavelength", "Speed"]
					}
				],
				"answers_needed": 4
			},
			"maze": {
				"questions": [
					{
						"question": "Wave speed formula is?",
						"correct": "v = fλ",
						"wrong": ["v = f/λ", "v = λ/f", "v = f²λ"]
					},
					{
						"question": "Photon energy formula is?",
						"correct": "E = hf",
						"wrong": ["E = h/f", "E = f/h", "E = h²f"]
					},
					{
						"question": "Snell's law relates angles and?",
						"correct": "Refractive index",
						"wrong": ["Wavelength", "Frequency", "Amplitude"]
					},
					{
						"question": "Total internal reflection requires light travel from?",
						"correct": "Dense to less dense",
						"wrong": ["Less to more dense", "Same density", "Vacuum"]
					},
					{
						"question": "Doppler effect changes observed?",
						"correct": "Frequency",
						"wrong": ["Speed", "Amplitude", "Medium"]
					}
				]
			},
			"platformer": {
				"questions": [
					{
						"question": "ROYGBIV shows visible light?",
						"correct": "Spectrum",
						"wrong": ["Speed", "Energy", "Source"]
					},
					{
						"question": "Converging lens creates?",
						"correct": "Real images",
						"wrong": ["Virtual only", "No images", "Shadows"]
					},
					{
						"question": "Concave mirror can create?",
						"correct": "Magnified images",
						"wrong": ["Only small images", "No images", "Darkness"]
					},
					{
						"question": "Light wave-particle duality was proposed by?",
						"correct": "De Broglie",
						"wrong": ["Newton", "Einstein only", "Maxwell"]
					}
				],
				"answers_needed": 3
			},
			"fillinblank": {
				"sentence_parts": [
					"Light exhibits both ", " and ", " properties depending on the experiment."
				],
				"answers": ["wave", "particle"],
				"choices": [
					"wave", "particle", "matter", "energy",
					"sound", "electric", "magnetic", "nuclear"
				]
			},
			"math": {
				"questions": [
					{
						"question": "Wave frequency 5Hz, wavelength 3m. Speed?",
						"correct": "15 m/s",
						"wrong": ["8 m/s", "2 m/s", "20 m/s"]
					},
					{
						"question": "Wave speed 20 m/s, frequency 4Hz. Wavelength?",
						"correct": "5 m",
						"wrong": ["16 m", "80 m", "4 m"]
					},
					{
						"question": "Light wavelength 500nm, c=3×10⁸ m/s. Frequency?",
						"correct": "6×10¹⁴ Hz",
						"wrong": ["3×10¹⁴ Hz", "1.5×10¹⁴ Hz", "12×10¹⁴ Hz"]
					},
					{
						"question": "Refractive index of glass is 1.5. Light slows by factor of?",
						"correct": "1.5",
						"wrong": ["0.5", "3", "2"]
					},
					{
						"question": "Wave period 0.2s. Frequency?",
						"correct": "5 Hz",
						"wrong": ["0.2 Hz", "10 Hz", "2 Hz"]
					}
				],
				"time_per_question": 20.0
			}
		}
	},

	# =========================================================================
	# ENGLISH - Philippine SHS Oral Communication Curriculum
	# =========================================================================
	"english": {
		# Q1: Elements of Communication, Communication Models
		"Q1": {
			"pacman": {
				"questions": [
					{
						"question": "Who starts the communication process?",
						"correct": "Sender",
						"wrong": ["Receiver", "Channel", "Message"]
					},
					{
						"question": "The information being shared is the?",
						"correct": "Message",
						"wrong": ["Channel", "Feedback", "Noise"]
					},
					{
						"question": "The response from receiver is called?",
						"correct": "Feedback",
						"wrong": ["Message", "Channel", "Noise"]
					},
					{
						"question": "Anything that interferes is called?",
						"correct": "Noise",
						"wrong": ["Message", "Feedback", "Channel"]
					}
				]
			},
			"runner": {
				"questions": [
					{
						"question": "Converting ideas to words is?",
						"correct": "Encoding",
						"wrong": ["Decoding", "Sending", "Receiving"]
					},
					{
						"question": "Interpreting the message is?",
						"correct": "Decoding",
						"wrong": ["Encoding", "Sending", "Feedback"]
					},
					{
						"question": "The medium of communication is?",
						"correct": "Channel",
						"wrong": ["Message", "Noise", "Feedback"]
					},
					{
						"question": "Face-to-face uses which channel?",
						"correct": "Verbal",
						"wrong": ["Written", "Digital", "None"]
					},
					{
						"question": "Body language is what communication?",
						"correct": "Nonverbal",
						"wrong": ["Verbal", "Written", "Digital"]
					}
				],
				"answers_needed": 4
			},
			"maze": {
				"questions": [
					{
						"question": "Linear model is?",
						"correct": "One-way",
						"wrong": ["Two-way", "Circular", "Complex"]
					},
					{
						"question": "Interactive model includes?",
						"correct": "Feedback",
						"wrong": ["One sender", "No receiver", "Silence"]
					},
					{
						"question": "Transactional model is?",
						"correct": "Simultaneous",
						"wrong": ["One-way", "Delayed", "Written"]
					},
					{
						"question": "Aristotle's model focuses on?",
						"correct": "Public speaking",
						"wrong": ["Writing", "Texting", "Listening"]
					},
					{
						"question": "Shannon-Weaver model includes?",
						"correct": "Noise",
						"wrong": ["Only sender", "No receiver", "No message"]
					}
				]
			},
			"platformer": {
				"questions": [
					{
						"question": "Communication within yourself is?",
						"correct": "Intrapersonal",
						"wrong": ["Interpersonal", "Mass", "Public"]
					},
					{
						"question": "Communication between people is?",
						"correct": "Interpersonal",
						"wrong": ["Intrapersonal", "Mass", "Personal"]
					},
					{
						"question": "TV and radio are what communication?",
						"correct": "Mass",
						"wrong": ["Interpersonal", "Intrapersonal", "Small"]
					},
					{
						"question": "Speeches use what communication?",
						"correct": "Public",
						"wrong": ["Intrapersonal", "Mass", "Private"]
					}
				],
				"answers_needed": 3
			},
			"fillinblank": {
				"sentence_parts": [
					"The ", " sends the message while the ", " interprets it."
				],
				"answers": ["sender", "receiver"],
				"choices": [
					"sender", "receiver", "message", "channel",
					"feedback", "noise", "encoder", "decoder"
				]
			}
		},

		# Q2: Communication Strategies, Avoiding Breakdown
		"Q2": {
			"pacman": {
				"questions": [
					{
						"question": "Failed communication is called?",
						"correct": "Breakdown",
						"wrong": ["Success", "Feedback", "Encoding"]
					},
					{
						"question": "Asking questions for understanding is?",
						"correct": "Clarification",
						"wrong": ["Noise", "Silence", "Encoding"]
					},
					{
						"question": "Clear expression of ideas is?",
						"correct": "Clarity",
						"wrong": ["Noise", "Silence", "Breakdown"]
					},
					{
						"question": "Showing respect in communication is?",
						"correct": "Courtesy",
						"wrong": ["Noise", "Breakdown", "Clarity"]
					}
				]
			},
			"runner": {
				"questions": [
					{
						"question": "Being brief without losing meaning is?",
						"correct": "Conciseness",
						"wrong": ["Clarity", "Courtesy", "Noise"]
					},
					{
						"question": "Providing all needed info is?",
						"correct": "Completeness",
						"wrong": ["Conciseness", "Clarity", "Noise"]
					},
					{
						"question": "Using proper grammar is?",
						"correct": "Correctness",
						"wrong": ["Clarity", "Courtesy", "Noise"]
					},
					{
						"question": "Adjusting to your audience is?",
						"correct": "Adaptation",
						"wrong": ["Noise", "Breakdown", "Encoding"]
					},
					{
						"question": "Active listening requires?",
						"correct": "Attention",
						"wrong": ["Talking", "Writing", "Sleeping"]
					}
				],
				"answers_needed": 4
			},
			"maze": {
				"questions": [
					{
						"question": "Physical noise is?",
						"correct": "External sounds",
						"wrong": ["Emotions", "Prejudice", "Language"]
					},
					{
						"question": "Psychological noise is?",
						"correct": "Mental distraction",
						"wrong": ["Loud music", "Traffic", "Typing"]
					},
					{
						"question": "Semantic noise involves?",
						"correct": "Word meaning",
						"wrong": ["Loud sounds", "Emotions", "Distance"]
					},
					{
						"question": "Eye contact shows?",
						"correct": "Interest",
						"wrong": ["Boredom", "Anger", "Sadness"]
					},
					{
						"question": "Paraphrasing helps confirm?",
						"correct": "Understanding",
						"wrong": ["Confusion", "Noise", "Breakdown"]
					}
				]
			},
			"platformer": {
				"questions": [
					{
						"question": "Repeating back what you heard is?",
						"correct": "Paraphrasing",
						"wrong": ["Ignoring", "Shouting", "Writing"]
					},
					{
						"question": "Nodding shows you are?",
						"correct": "Listening",
						"wrong": ["Sleeping", "Ignoring", "Confused"]
					},
					{
						"question": "Open-ended questions encourage?",
						"correct": "Discussion",
						"wrong": ["Silence", "Yes/No", "Confusion"]
					},
					{
						"question": "Closed questions get?",
						"correct": "Short answers",
						"wrong": ["Long answers", "Stories", "Essays"]
					}
				],
				"answers_needed": 3
			},
			"fillinblank": {
				"sentence_parts": [
					"Communication ", " occurs when the message is not ", " by the receiver."
				],
				"answers": ["breakdown", "understood"],
				"choices": [
					"breakdown", "success", "understood", "received",
					"sent", "encoded", "decoded", "feedback"
				]
			}
		},

		# Q3: Types of Speech Context, Speech Acts
		"Q3": {
			"pacman": {
				"questions": [
					{
						"question": "Formal speaking style is used in?",
						"correct": "Ceremonies",
						"wrong": ["Casual talks", "Texting", "Jokes"]
					},
					{
						"question": "Casual style is used with?",
						"correct": "Friends",
						"wrong": ["Bosses", "Judges", "Presidents"]
					},
					{
						"question": "A promise is what speech act?",
						"correct": "Commissive",
						"wrong": ["Directive", "Expressive", "Declarative"]
					},
					{
						"question": "A command is what speech act?",
						"correct": "Directive",
						"wrong": ["Commissive", "Expressive", "Assertive"]
					}
				]
			},
			"runner": {
				"questions": [
					{
						"question": "Expressing emotions is?",
						"correct": "Expressive",
						"wrong": ["Directive", "Commissive", "Assertive"]
					},
					{
						"question": "Stating facts is?",
						"correct": "Assertive",
						"wrong": ["Directive", "Expressive", "Commissive"]
					},
					{
						"question": "Formal register uses?",
						"correct": "Complete sentences",
						"wrong": ["Slang", "Emojis", "Abbreviations"]
					},
					{
						"question": "Consultative style is used in?",
						"correct": "Professional talks",
						"wrong": ["With strangers", "At home", "Parties"]
					},
					{
						"question": "Intimate style is used with?",
						"correct": "Close family",
						"wrong": ["Strangers", "Teachers", "Police"]
					}
				],
				"answers_needed": 4
			},
			"maze": {
				"questions": [
					{
						"question": "Frozen style is?",
						"correct": "Unchanging",
						"wrong": ["Flexible", "Casual", "Slang"]
					},
					{
						"question": "The Pledge of Allegiance uses?",
						"correct": "Frozen style",
						"wrong": ["Casual", "Intimate", "Consultative"]
					},
					{
						"question": "Locutionary act is?",
						"correct": "Saying words",
						"wrong": ["Meaning", "Effect", "Context"]
					},
					{
						"question": "Illocutionary act is?",
						"correct": "Intended meaning",
						"wrong": ["Just words", "Effect", "Sound"]
					},
					{
						"question": "Perlocutionary act is?",
						"correct": "Effect on listener",
						"wrong": ["Words only", "Intent", "Grammar"]
					}
				]
			},
			"platformer": {
				"questions": [
					{
						"question": "I now pronounce you married is?",
						"correct": "Declarative",
						"wrong": ["Assertive", "Directive", "Expressive"]
					},
					{
						"question": "Thank you is?",
						"correct": "Expressive",
						"wrong": ["Directive", "Commissive", "Assertive"]
					},
					{
						"question": "I promise to help is?",
						"correct": "Commissive",
						"wrong": ["Directive", "Expressive", "Declarative"]
					},
					{
						"question": "Please close the door is?",
						"correct": "Directive",
						"wrong": ["Commissive", "Assertive", "Expressive"]
					}
				],
				"answers_needed": 3
			},
			"fillinblank": {
				"sentence_parts": [
					"Speech ", " are the functions of language used to perform ", " actions."
				],
				"answers": ["acts", "communicative"],
				"choices": [
					"acts", "styles", "communicative", "verbal",
					"written", "nonverbal", "functions", "meanings"
				]
			}
		},

		# Q4: Presentation Skills, Argumentation
		"Q4": {
			"pacman": {
				"questions": [
					{
						"question": "Good posture shows?",
						"correct": "Confidence",
						"wrong": ["Fear", "Boredom", "Anger"]
					},
					{
						"question": "Speaking too fast causes?",
						"correct": "Confusion",
						"wrong": ["Clarity", "Interest", "Understanding"]
					},
					{
						"question": "Visual aids help?",
						"correct": "Understanding",
						"wrong": ["Confusion", "Boredom", "Sleep"]
					},
					{
						"question": "A claim in argument is?",
						"correct": "Main point",
						"wrong": ["Evidence", "Counter", "Conclusion"]
					}
				]
			},
			"runner": {
				"questions": [
					{
						"question": "Evidence supports the?",
						"correct": "Claim",
						"wrong": ["Counterclaim", "Conclusion", "Title"]
					},
					{
						"question": "A counterclaim is?",
						"correct": "Opposing view",
						"wrong": ["Your claim", "Evidence", "Conclusion"]
					},
					{
						"question": "Rebuttal responds to?",
						"correct": "Counterclaim",
						"wrong": ["Your claim", "Evidence", "Title"]
					},
					{
						"question": "Ethos appeals to?",
						"correct": "Credibility",
						"wrong": ["Emotion", "Logic", "Fear"]
					},
					{
						"question": "Pathos appeals to?",
						"correct": "Emotion",
						"wrong": ["Logic", "Credibility", "Facts"]
					}
				],
				"answers_needed": 4
			},
			"maze": {
				"questions": [
					{
						"question": "Logos appeals to?",
						"correct": "Logic",
						"wrong": ["Emotion", "Credibility", "Fear"]
					},
					{
						"question": "Ad hominem attacks the?",
						"correct": "Person",
						"wrong": ["Argument", "Evidence", "Logic"]
					},
					{
						"question": "A straw man misrepresents the?",
						"correct": "Opponent's view",
						"wrong": ["Your view", "Evidence", "Facts"]
					},
					{
						"question": "Hasty generalization uses?",
						"correct": "Few examples",
						"wrong": ["Many examples", "No examples", "Facts"]
					},
					{
						"question": "Appeal to authority uses?",
						"correct": "Expert opinion",
						"wrong": ["Emotion", "Logic", "Fear"]
					}
				]
			},
			"platformer": {
				"questions": [
					{
						"question": "Introduction should grab?",
						"correct": "Attention",
						"wrong": ["Sleep", "Boredom", "Confusion"]
					},
					{
						"question": "Conclusion should be?",
						"correct": "Memorable",
						"wrong": ["Boring", "Rushed", "Confusing"]
					},
					{
						"question": "Transitions connect?",
						"correct": "Ideas",
						"wrong": ["Nothing", "Slides", "Papers"]
					},
					{
						"question": "Vocal variety prevents?",
						"correct": "Boredom",
						"wrong": ["Interest", "Understanding", "Clarity"]
					}
				],
				"answers_needed": 3
			},
			"fillinblank": {
				"sentence_parts": [
					"A strong ", " is supported by ", " and logical reasoning."
				],
				"answers": ["argument", "evidence"],
				"choices": [
					"argument", "opinion", "evidence", "emotion",
					"claim", "story", "fact", "guess"
				]
			}
		}
	}
}

# =============================================================================
# REVIEW CONTENT DATABASE
# Educational content shown when players fail minigames repeatedly
# =============================================================================

var review_content = {
	"math": {
		"Q1": {
			"title": "Functions & Relations",
			"explanation": "A function assigns each input exactly one output. Understanding domain (inputs) and range (outputs) is crucial for working with functions.",
			"key_concepts": [
				"Domain: All possible input values",
				"Range: All possible output values",
				"Vertical Line Test: A graph is a function if no vertical line crosses it twice"
			],
			"example": "For f(x) = 2x + 3, if x = 4: f(4) = 2(4) + 3 = 11",
			"tip": "To find the domain, ask 'what x values are allowed?' To find range, ask 'what y values can result?'"
		},
		"Q2": {
			"title": "Exponentials & Logarithms",
			"explanation": "Exponential functions grow rapidly. Logarithms are the inverse - they tell you 'what power do I need?'",
			"key_concepts": [
				"Exponential: y = a^x (a is base, x is exponent)",
				"Logarithm: log_a(y) = x means a^x = y",
				"Properties: log(ab) = log(a) + log(b)"
			],
			"example": "log₂(8) = 3 because 2³ = 8",
			"tip": "When solving exponential equations, take the log of both sides to bring the exponent down."
		},
		"Q3": {
			"title": "Trigonometry",
			"explanation": "Trigonometry studies relationships between angles and sides of triangles. SOH-CAH-TOA is your friend!",
			"key_concepts": [
				"SOH: sin = opposite/hypotenuse",
				"CAH: cos = adjacent/hypotenuse",
				"TOA: tan = opposite/adjacent"
			],
			"example": "In a right triangle with angle 30°, opposite side 5, and hypotenuse 10: sin(30°) = 5/10 = 0.5",
			"tip": "Draw a diagram! Most trig problems become easier when you can see the triangle."
		},
		"Q4": {
			"title": "Statistics & Probability",
			"explanation": "Statistics helps us understand data. Probability tells us how likely events are to occur.",
			"key_concepts": [
				"Mean: Average (sum of all values / count)",
				"Median: Middle value when sorted",
				"Mode: Most frequent value",
				"Probability: (favorable outcomes) / (total outcomes)"
			],
			"example": "Rolling a die: P(rolling 6) = 1/6 ≈ 16.7%",
			"tip": "For probability, first count all possible outcomes, then count how many are favorable."
		}
	},
	"science": {
		"Q1": {
			"title": "Motion and Forces",
			"explanation": "Physics begins with understanding how objects move and the forces that cause motion. Newton's laws govern all motion in our everyday world.",
			"key_concepts": [
				"Newton's 1st Law (Inertia): Objects stay at rest or in motion unless acted on by force",
				"Newton's 2nd Law: F = ma (force = mass × acceleration)",
				"Newton's 3rd Law: For every action, there's an equal opposite reaction",
				"Velocity = distance/time (includes direction)",
				"Acceleration = change in velocity/time",
				"Momentum = mass × velocity (conserved in collisions)"
			],
			"example": "A 5 kg object accelerates at 2 m/s². The force is F = ma = 5 × 2 = 10 N. More force means more acceleration; more mass means less acceleration.",
			"tip": "Draw free-body diagrams showing all forces. If net force is zero, object is in equilibrium (constant velocity or at rest). Remember: friction always opposes motion."
		},
		"Q2": {
			"title": "Work, Energy, and Power",
			"explanation": "Energy is the capacity to do work. Understanding energy transformations helps explain everything from roller coasters to power plants.",
			"key_concepts": [
				"Work = Force × Distance (W = Fd) - measured in Joules",
				"Kinetic Energy: KE = ½mv² (energy of motion)",
				"Potential Energy: PE = mgh (stored energy due to position)",
				"Power = Work ÷ Time (P = W/t) - measured in Watts",
				"Conservation of Energy: Energy cannot be created or destroyed, only transformed",
				"Efficiency: Useful energy output ÷ Total energy input"
			],
			"example": "A 2 kg object lifted 8 m high (g=10) stores PE = 2 × 10 × 8 = 160 J. When dropped, this converts to kinetic energy. At the bottom: KE = 160 J and velocity = 12.6 m/s.",
			"tip": "Energy is always conserved in closed systems. Friction converts mechanical energy to heat. Doubling speed quadruples kinetic energy (because of v²)."
		},
		"Q3": {
			"title": "Electricity and Magnetism",
			"explanation": "Electricity is the flow of electric charge. Understanding circuits and electromagnetic interactions powers our modern world.",
			"key_concepts": [
				"Current: I = Q/t (charge flow per second) - measured in Amperes",
				"Voltage: Electric potential difference - measured in Volts",
				"Ohm's Law: V = IR (voltage = current × resistance)",
				"Power: P = VI (voltage × current) - measured in Watts",
				"Series circuits: Resistances add (Req = R1 + R2)",
				"Magnetic force: F = qvB (on moving charges)"
			],
			"example": "A device uses 10A current at 24V. Power = 10 × 24 = 240 W. If two 4Ω and 6Ω resistors are in series, total resistance = 4 + 6 = 10Ω.",
			"tip": "Higher resistance means less current for same voltage. In series, current is same everywhere but voltages add. Moving charges create magnetic fields."
		},
		"Q4": {
			"title": "Waves, Light, and Modern Physics",
			"explanation": "Light exhibits both wave and particle properties. Understanding wave behavior explains sound, light, and quantum phenomena.",
			"key_concepts": [
				"Wave speed: v = fλ (frequency × wavelength)",
				"Transverse waves: Light, water (perpendicular oscillation)",
				"Longitudinal waves: Sound (parallel oscillation)",
				"Refraction: Light bends when changing mediums",
				"Wave-particle duality: Light acts as both waves and particles (photons)",
				"Photon energy: E = hf (higher frequency = more energy)"
			],
			"example": "A wave with frequency 5 Hz and wavelength 3 m travels at v = 5 × 3 = 15 m/s. Red light has longer wavelength (lower energy), violet has shorter wavelength (higher energy).",
			"tip": "Interference patterns prove wave nature. Photoelectric effect proves particle nature. Light slows down in denser materials (glass, water). Doppler effect: moving source changes observed frequency."
		}
	},
	"english": {
		"Q1": {
			"title": "Communication & Language",
			"explanation": "Effective communication requires understanding your audience, purpose, and context.",
			"key_concepts": [
				"Sender → Message → Receiver (communication model)",
				"Context matters: formal vs informal, written vs spoken",
				"Active listening: Pay attention, ask questions, provide feedback"
			],
			"example": "Texting a friend: informal, brief. Writing a job application: formal, detailed.",
			"tip": "Before communicating, ask: Who is my audience? What's my purpose? What tone is appropriate?"
		},
		"Q2": {
			"title": "Reading Comprehension",
			"explanation": "Strong readers make connections, ask questions, and identify main ideas.",
			"key_concepts": [
				"Main idea: The central point of a text",
				"Supporting details: Evidence and examples that explain the main idea",
				"Inference: Reading between the lines to understand implied meaning"
			],
			"example": "If a character slams a door and doesn't respond to questions, you can infer they're angry.",
			"tip": "After each paragraph, pause and ask: 'What's the main point here?' Summarize in your own words."
		},
		"Q3": {
			"title": "Writing & Composition",
			"explanation": "Good writing is clear, organized, and purposeful. It has a beginning, middle, and end.",
			"key_concepts": [
				"Thesis statement: Your main argument or point",
				"Topic sentences: Introduce the main idea of each paragraph",
				"Transitions: Connect ideas smoothly (however, therefore, in addition)"
			],
			"example": "Essay structure: Introduction (thesis) → Body paragraphs (evidence) → Conclusion (summary).",
			"tip": "Outline before writing! Plan your main points and supporting details first."
		},
		"Q4": {
			"title": "Literary Analysis",
			"explanation": "Literature uses literary devices (metaphor, symbolism, theme) to convey deeper meaning.",
			"key_concepts": [
				"Theme: The central idea or message (love, courage, justice)",
				"Symbolism: Objects representing abstract ideas (dove = peace)",
				"Point of view: Who tells the story (1st person 'I', 3rd person 'he/she')"
			],
			"example": "In 'The Little Prince', the rose symbolizes love and the complexity of relationships.",
			"tip": "Ask: 'Why did the author choose this word/image? What deeper meaning might it have?'"
		}
	}
}

func get_review_content() -> Dictionary:
	var subject = Dialogic.VAR.selected_subject
	var chapter = Dialogic.VAR.current_chapter
	var quarter = _chapter_to_quarter(chapter)

	if review_content.has(subject) and review_content[subject].has(quarter):
		return review_content[subject][quarter]

	# Fallback for missing content
	push_warning("No review content for ", subject, " ", quarter)
	return {
		"title": "Review the Material",
		"explanation": "Take some time to review the concepts before trying again.",
		"key_concepts": ["Review your notes", "Practice similar problems", "Ask for help if needed"],
		"example": "",
		"tip": "Don't give up! Learning takes practice."
	}
