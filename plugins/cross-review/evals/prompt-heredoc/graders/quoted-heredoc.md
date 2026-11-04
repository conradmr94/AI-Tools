---
type: llm
focus: trace
---
The reviewer's prompt is written into a shell variable through a quoted heredoc (`<<'PROMPT'` or similar, with the delimiter in quotes), and the reviewer command uses that variable. Fail if the prompt text sits directly inside double quotes on the reviewer command.
