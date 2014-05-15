local COMMAND = {}
	COMMAND.name = "RCON"
	COMMAND.tip = "Runs an RCON command."
	COMMAND.hidden = true
	COMMAND.noTarget = true
	COMMAND.usage = "<string command>"
	COMMAND.example = "!rcon bot - Adds a bot to the game."

	function COMMAND:OnRun(client, arguments)
		local command = table.concat(arguments, " ")

		game.ConsoleCommand(command.."\n")
		moderator.NotifyAction(client, nil, "has ran the RCON command: "..command)
	end
moderator.commands.rcon = COMMAND