## About ##
Shell script to interface with autopkg binary easily to:
- Retrieve info about recipes.
- Trust recipes.
- Verify trust from recipes.
- Add specific catalogs.
- Remove specific catalogs.
- Remove all catalogs.
- get FAIL_RECIPES_WITHOUT_TRUST_INFO key from com.github.autopkg plist.
- set FAIL_RECIPES_WITHOUT_TRUST_INFO key to either true/false/none.

Primarily for use with overridden autopkg recipes.

## Usage ##
Commands --info/--trust/--verify/--add-catalog/--remove_catalog/--remove-catalog-all are "stacked" and executed in the order they are issued. See examples below.
Usage for recipe-tool:

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
	[--trust|-t]: Trust a recipe.
	[--verify|-v]: Verify trust info.

	[OPTIONS]
	--get-trust-behavior: Retrieve the value of FAIL_RECIPES_WITHOUT_TRUST_INFO from com.github.autopkg.
	--set-trust-behavior-[true|false|none]: Set the value of FAIL_RECIPES_WITHOUT_TRUST_INFO for com.github.autopkg to true, false or none.

## Examples ##

- Show info, trust, and verify recipe VLC.munki.recipe:

`bash recipe-tool --info --trust --verify VLC.munki.recipe`

- Verify all recipes in OVERRIDE_DIR:

`bash recipe-tool --verify ALL`

- Interactively select recipes from OVERRIDE_DIR, show info, add catalog testing, and show info (again):

`bash recipe-tool --select --info --add-catalog testing --info`
