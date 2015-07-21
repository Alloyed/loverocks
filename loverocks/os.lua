-- basic runtime test. installed versions will be hardcoded
return os.getenv("HOME") and "unix" or "windows"
