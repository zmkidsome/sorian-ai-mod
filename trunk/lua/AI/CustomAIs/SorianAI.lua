#****************************************************************************
#**
#**  File     :  /lua/AI/CustomAIs/SorianAI.lua
#**  Author(s): Michael Robbins aka Sorian
#**
#**  Summary  : Utility File to insert custom AI into the game.
#**
#****************************************************************************

local AIVersion = "1.8.3b"

AI = {
	Name = "Sorian AI",
	Version = AIVersion,
	AIList = {
		{
			key = 'sorian',
			name = "AI: SAI "..AIVersion,
		},
		{
			key = 'sorianrush',
			name = "AI: SAI Rush "..AIVersion,
		},
		{
			key = 'sorianair',
			name = "AI: SAI Air "..AIVersion,
		},
		{
			key = 'sorianwater',
			name = "AI: SAI Water "..AIVersion,
		},
		{
			key = 'sorianturtle',
			name = "AI: SAI Turtle "..AIVersion,
		},
		{
			key = 'sorianadaptive',
			name = "AI: SAI Adaptive "..AIVersion,
		},
	},
	CheatAIList = {
		{
			key = 'soriancheat',
			name = "AIx: SAI "..AIVersion,
		},
		{
			key = 'sorianrushcheat',
			name = "AIx: SAI Rush "..AIVersion,
		},
		{
			key = 'sorianaircheat',
			name = "AIx: SAI Air "..AIVersion,
		},
		{
			key = 'sorianwatercheat',
			name = "AIx: SAI Water "..AIVersion,
		},
		{
			key = 'sorianturtlecheat',
			name = "AIx: SAI Turtle "..AIVersion,
		},
		{
			key = 'sorianadaptivecheat',
			name = "AIx: SAI Adaptive "..AIVersion,
		},
	},
}