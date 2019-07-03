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
	[--name|-n] recipe: Specifiy a recipe name. Use this flage for each recipe. Specifying 'ALL' will select all recipes available in the OVERRIDE_DIR.
	--override-dir absolute-path-to-dir: Set the Override Directory. Default: /Users/cgomez/Library/AutoPkg/RecipeRepos/
	[--select|-s]: Interactively select a recipe from specified Override Directory. Default: OFF
	[--trust|-t]: Trust a recipe. Default: OFF
	[--verify|-v]: Verify trust info. Default: OFF

	[OPTIONS]
	--get-trust-behavior: Retrieve the value of FAIL_RECIPES_WITHOUT_TRUST_INFO from com.github.autopkg.
	--set-trust-behavior-[true|false|none]: Set the value of FAIL_RECIPES_WITHOUT_TRUST_INFO for com.github.autopkg to true, false or none.
