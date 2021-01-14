-- TODO profile why loading is slow

local function lib()
	local function mut_append2(table1, table2)
		local len = #table1
		for i = 1, #table2 do
			table1[len + i] = table2[i]
		end
	end
 
	local function mut_append(tab, val, ...)
		if val == nil
			then return tab
			else
				table.insert(tab, val)
				return mut_append(tab, ...)
		end
	end

	local function pop(tab)
		local val = tab[#tab]
		table.remove(tab)
		return val
	end

	return { ["pop"] = pop, ["mut_append"] = mut_append, ["mut_append2"] = mut_append2 }
end
local lib = lib()

-- Functionality for making plugin development a little more convenient:
-- This  provides a key binding to reload the editor.
local function selfexec()
	local micro = import("micro")
	local config = import("micro/config")
	local os = import("os")
	local syscall = import("syscall")

	-- TODO nag upstream about whether there is a better way
	local plugd = config.ConfigDir .. "/plug/selfexec"

	local function selfexec()
		 -- Calling exec somehow messes up the teminal state.
		 -- we use a wrapper script that calls the `reset` command to fix the shell, and then execs its argv
		local wrapper = plugd .. "/execwrapper.sh"

		-- For some reason calling (this?) exec overwrites the argv0 meaning it points to the execme.sh
		-- The workaround is to pass the entire old argv shifted by one, so the original executable is also
		-- passed as an argument. E.g.:
		-- [ "execwrapper.sh", "-debug", "whatever.file" ] -> [ "execwrapper.sh", "micro", "-debug", "whatever,file" ]
		-- If we were directly exec-ing outselves, we wouldn't need to worry about argv[0].
		local args = { wrapper } -- This first value could be anything?
		lib.mut_append2(args, os.Args)

		-- Due to the fact that exec is an unclean shutdown method, micro will nag about restoring backups,
		-- even if we saved the document properly. We turn on manual backup handling after a reload to work around this. 
		-- TODO can we do a clean "shutdown" before we call exec?
		if not config.GetGlobalOption("permbackup") then 
			-- the only state we keep is open files and we assume the last argument is the only opened file
			-- TODO nag upstream about enumerating / accessing buffers -- https://github.com/zyedidia/micro/issues/1993  Lua: methods to access open buffers
			-- TODO multiple files, maybe serialized layout? / other stuff - 
			--  going full xmonad here...how much state can we reasonably serialize?
			local file = lib.pop(args)
			lib.mut_append(args, "-permbackup", "true", file) --TODO well really I should just rewrit this as "insert after flags position" no?
		end

		micro.Log("Attempting reload with args.."); micro.Log(args)
		syscall.Exec(wrapper, args, os.Environ())
	end

	local function doBind()
		config.TryBindKey("Ctrl-r", "lua:selfexec._selfexec", true)
	end

	local function init()
        micro.Log("Loaded with args..."); micro.Log(os.Args)
		doBind()
	end

	init()
	return { ["selfexec"] = selfexec }
end
_selfexec = selfexec().selfexec --TODO get upstream to support this -- https://github.com/zyedidia/micro/issues/1989 Accept arbitrary lua expression in LuaAction / "lua:" binding target
