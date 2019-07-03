## About ##
Shell script to interface with autopkg binary easily to:
- Retrieve info about recipes.
- Trust recipes.
- Verify trust from recipes.

Primarily for use with overridden autopkg recipes.

## Usage ##

	--garbage-collect: Toggle garbage-collect flag. Removes all files/directory variables in GARBAGE array. Default: OFF
	--debug: Toggle Debugging. Default: OFF
	--force: Answer 'yes'/'y' to all questions. (aka force) Default: OFF
	[--help|-h]: Display this dialog
	[--logging|-l]: Toggle logging. Default: OFF
	--logfile filename: Specifiy the logfile output.

	[OPTIONS] [RECIPE_NAME]
	[--info|-i]: Show recipe info. Default: OFF
	--override-dir absolute-path-to-dir: Set the Override Directory.
	[--select|-s]: Interactively select a recipe from specified Override Directory. Default: OFF
	[--trust|-t]: Trust a recipe. Default: OFF
	[--verify|-v]: Verify trust info. Default: OFF
