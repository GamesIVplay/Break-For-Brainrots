return function(registry)
    registry:RegisterHook("BeforeRun", function(context)
        if context.Executor.UserId ~= 3439160531 then
            return "You don't have permission to run commands"
        end

        return
    end)
end
