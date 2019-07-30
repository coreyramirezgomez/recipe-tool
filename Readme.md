## About ##
Shell script to interface with autopkg binary easily to:
- Retrieve info about recipes.
- Trust recipes.
- Verify trust from recipes.

Primarily for use with overridden autopkg recipes.

## Usage ##

	--garbage-collect: Toggle garbage-collect flag. Removes all files/directory variables in GARBAGE array.
	--debug: Toggle Debugging.
	--force: Answer 'yes'/'y' to all questions. (aka force)
	[--help|-h]: Display this dialog
	[--logging|-l]: Toggle logging.
	--logfile filename: Specifiy the logfile output.

	[OPTIONS] [RECIPE_NAME]
	[--info|-i]: Show recipe info.
	[--name|-n] recipe: Specifiy a recipe name. Use this flage for each recipe. Specifying 'ALL' will select all recipes available in the OVERRIDE_DIR.
	--override-dir absolute-path-to-dir: Set the Override Directory.
	[--select|-s]: Interactively select a recipe from specified Override Directory.
	--add-catalog catalog: Add a catalog to a recipe.
	--remove-catalog catalog: Remove a catalog from a recipe.
	--remove-catalog-all: Remove all catalogs from a recipe.
	--format-repo-subdir: Format the MUNKI_REPO_SUBDIR to be developer_name/app_name.
