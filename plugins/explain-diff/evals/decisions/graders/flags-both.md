---
type: llm
---
The response has a section of decisions nobody asked for, and it names both: (1) the hard-coded 30-second timeout (DEFAULT_TIMEOUT_SECONDS in config.py), and (2) ApiClient.get catching every exception and returning None, which hides transport errors. Each is given with its file.
