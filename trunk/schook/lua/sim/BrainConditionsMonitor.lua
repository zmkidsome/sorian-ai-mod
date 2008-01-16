do

BrainConditionsMonitor = Class {

    PreCreate = function(self)
        if self.PreCreateFinished then
            return true
        end

        self.Trash = TrashBag()
        
        self.ThreadWaitDuration = 7
        
        self.Brain = false
        self.Active = false
        
        self.ResultTable = {}
        self.ConditionData = {
            TableConditions = {},
            FunctionConditions = {},
        }
        self.ConditionsTable = {}
                
        self.PreCreateFinished = true
    end,
    
    # Create the thing
    Create = function(self, brain)
        if not self.PreCreateFinished then
            self:PreCreate()
        end
        self.Brain = brain
    end,

    # Gets result for the keyed condition
    CheckKeyedCondition = function(self, conditionKey, reportFailure)
        if self.ResultTable[conditionKey] != nil then
            return self.ResultTable[conditionKey]:GetStatus(reportFailure)
        end
        WARN('*WARNING: No Condition found with condition key: ' .. conditionKey)
        return false
    end,
    
    # Checks the condition and returns the result
    CheckConditionTable = function(self, cFilename, cFunctionName, cData)
        if not cData or not type(cData) == 'table' then
            WARN('*WARNING: Invalid argumetns for build condition: ' .. cFilename .. '[' .. cFunctionName .. ']')
            return false
        end
        return import(cFilename)[cFunctionName](self.Brain, unpack(cData))
    end,
    
    # Runs the function and retuns the result
    CheckConditionFunction = function(self, func, params)
        return func(unpack(params))
    end,
    
    # Find the key for a condition or adds it to the table and checks the condition
    GetConditionKey = function(self, cFilename, cFunctionName, cData)
        if not cFunctionName then
            error('*BUILD CONDITION MONITOR: Invalid BuilderCondition - Missing function name')
        elseif not cData or type(cData) != 'table' then
            error('*BUILD CONDITION MONITOR: Invalid BuilderCondition - Missing data table')
        end
        
        # Key the TableConditions by filename
        if not self.ConditionData.TableConditions[cFilename] then
            self.ConditionData.TableConditions[cFilename] = {}
        end
        
        # Key the filenames by function name
        if not self.ConditionData.TableConditions[cFilename][cFunctionName] then
            self.ConditionData.TableConditions[cFilename][cFunctionName] = {}
        end
        
        # Check if the cData matches up
        for num,data in self.ConditionData.TableConditions[cFilename][cFunctionName] do
            # Check if the data is the same length
            if table.getn(data.ConditionParameters) == table.getn(cData) then
                local match = true
                # Check each piece of data to make sure it matches
                for k,v in data.ConditionParameters do
                    if v != cData[k] then
                        match = false
                        break
                    end
                end
                # Match found, return the key
                if match then
                    return data.Key
                end
            end
        end
        
        # No match found, so add the data to the table and return the key (same number as num items)
        local newCondition
        if cFilename == '/lua/editor/InstantBuildConditions.lua' 
            or cFilename == '/lua/editor/UnitCountBuildConditions.lua' or cFilename == '/lua/editor/EconomyBuildConditions.lua' 
			or cFilename == '/lua/editor/SorianInstantBuildConditions.lua' then
            newCondition = InstantImportCondition()
        else
            newCondition = ImportCondition()
        end
        newCondition:Create(self.Brain, table.getn(self.ResultTable) + 1, cFilename, cFunctionName, cData)
        table.insert( self.ResultTable, newCondition )
        
        # Add in a hashed table for quicker key lookup, may not be necessary
        local newTable = { 
            ConditionParameters = cData, 
            Key = newCondition:GetKey(),
        }
        table.insert( self.ConditionData.TableConditions[cFilename][cFunctionName], newTable )
        return newTable.Key
    end,
    
    # Find the key for a condition that is a function
    GetConditionKeyFunction = function(self, func, parameters)
        # See if there is a matching function
        for k,v in self.ConditionData.FunctionConditions do
            if v.Function == func then
                local found = true
                for num,data in v.ConditionParameters do
                    if data != parameters[num] then
                        found = false
                        break
                    end
                end
                if found then
                    return v.Key
                end
            end
        end
        
        # No match, insert data into the function conditions table
        local newCondition = FunctionCondition()
        newCondition:Create(self.Brain, table.getn(self.ResultTable) + 1, func, parameters )
        table.insert( self.ResultTable, newCondition )
        
        local newTable = {
            Function = func,
            Key = newCondition:GetKey(),
            ConditionParameters = parameters,
        }
        table.insert( self.ConditionData.FunctionConditions, newTable )
        return newTable.Key
    end,
    
    # Thread that will monitor conditions the brain asks for over time
    ConditionMonitorThread = function(self)
        while true do
            local checks = 0
            local numChecks = table.getn(self.ResultTable)
            local numPerTick = math.ceil( numChecks / ( self.ThreadWaitDuration * 10 ) )
            
            for k,v in self.ResultTable do
                v:CheckCondition()
                
                # Load balance per tick here
                checks = checks + 1
                if checks >= numPerTick then
                    WaitTicks(1)
                    checks = 0
                end
            end
            WaitTicks(1)
        end
    end,
    
    # Adds a condition to the table and returns the key
    AddCondition = function(self, cFilename, cFunctionName, cData)
        if not self.Active then
            self.Active = true
            self:ForkThread(self.ConditionMonitorThread)
        end
        if type(cFilename) == 'function' then
            return self:GetConditionKeyFunction(cFilename, cFunctionName)
        end
        return self:GetConditionKey(cFilename, cFunctionName, cData)
    end,
    
    # forking and storing a thread on the monitor
    ForkThread = function(self, fn, ...)
        if fn then
            local thread = ForkThread(fn, self, unpack(arg))
            self.Trash:Add(thread)
            return thread
        else
            return nil
        end
    end,
}

end