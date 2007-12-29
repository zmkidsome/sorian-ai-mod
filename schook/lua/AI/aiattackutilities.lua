do

function PlatoonGenerateSafePathTo(aiBrain, platoonLayer, start, destination, optThreatWeight, optMaxMarkerDist)   
        
    local location = start
    optMaxMarkerDist = optMaxMarkerDist or 250
    optThreatWeight = optThreatWeight or 1
    local finalPath = {}
	local testPath = false
	
	local per = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
	
	if per == 'sorian' or per == 'sorianrush' then testPath = true end
	
	if VDist2( start[1], start[3], destination[1], destination[3] ) < 100 and (per == 'sorian' or per == 'sorianrush') then
		table.insert(finalPath, destination)    
		return finalPath
	end
	
    --Get the closest path node at the platoon's position
    local startNode = GetClosestPathNodeInRadiusByLayer(location, optMaxMarkerDist, platoonLayer)
    if not startNode and platoonLayer == 'Amphibious' then
        return PlatoonGenerateSafePathTo(aiBrain, 'Land', start, destination, optThreatWeight, optMaxMarkerDist)
    end
    if not startNode then return false, 'NoStartNode' end
    
    --Get the matching path node at the destiantion
    local endNode = GetClosestPathNodeInRadiusByGraph(destination, optMaxMarkerDist, startNode.graphName)
    if not endNode and platoonLayer == 'Amphibious' then
        return PlatoonGenerateSafePathTo(aiBrain, 'Land', start, destination, optThreatWeight, optMaxMarkerDist)
    end    
    if not endNode then return false, 'NoEndNode' end
    
     --Generate the safest path between the start and destination
    local path = GeneratePath(aiBrain, startNode, endNode, ThreatTable[platoonLayer], optThreatWeight, destination, testPath)
    if not path and platoonLayer == 'Amphibious' then
        return PlatoonGenerateSafePathTo(aiBrain, 'Land', start, destination, optThreatWeight, optMaxMarkerDist)
    end    
    if not path then return false, 'NoPath' end
        
    --Insert the path nodes (minus the start node and end nodes, which are close enough to our start and destination) into our command queue.
    #local finalPath = {}
    for i,node in path.path do
        if i > 1 and i < table.getn(path.path) then
              #platoon:MoveToLocation(node.position, false)
              table.insert(finalPath, node.position)
          end
    end

    #platoon:MoveToLocation(destination, false)
    table.insert(finalPath, destination)
    
    return finalPath
end

function GeneratePath(aiBrain, startNode, endNode, threatType, threatWeight, destination, testPath)
    threatWeight = threatWeight or 1
    
    local graph = GetPathGraphs()[startNode.layer][startNode.graphName]
    
    --ZOMG A*
    local closed = {}
    
    --Queue will be sorted such that best path is at the end.
    local queue = { 
        {
            cost = 0, 
            path = {startNode, }, 
            threat = 0
        }
    }
    
    --I didn't know we had a continue statement when I wrote this, and this was a workaround to avoid using continue. :(
    local AStarLoopBody = function()
        local curPath = table.remove(queue)
        local lastNode = curPath.path[table.getn(curPath.path)]
        
        if closed[lastNode] then return false end
		
		local dist2 = VDist2(lastNode.position[1], lastNode.position[3], destination[1], destination[3])
        
        if lastNode == endNode or (dist2 < 100 and testPath and lastNode != startNode) then
			return curPath
		end
        
        closed[lastNode] = true
        
        local mapSizeX = ScenarioInfo.size[1]
        local mapSizeZ = ScenarioInfo.size[2]
        for i, adjacentNode in lastNode.adjacent do
            local fork = {
                cost = curPath.cost, 
                path = {unpack(curPath.path)}, 
                threat = curPath.threat
            }
            
            local newNode = graph[adjacentNode]
            
            if newNode then
                --get distance from new node to end node
                local dist = VDist2Sq(newNode.position[1], newNode.position[3], endNode.position[1], endNode.position[3])

                # this brings the dist value from 0 to 100% of the maximum length with can travel on a map
                dist = 100 * dist / ( mapSizeX + mapSizeZ ) #(mapSizeX * mapSizeX  + mapSizeZ * mapSizeZ)
                
                --get threat from current node to adjacent node
                local threat = aiBrain:GetThreatBetweenPositions(newNode.position, lastNode.position, nil, threatType)
                           
                --update path stuff
                fork.cost = fork.cost + dist + threat*threatWeight
                fork.threat = fork.threat + threat
                
                --add the node to the path
                table.insert(fork.path, newNode)
                table.insert(queue,fork)
             end
        end
        
        --sort queue
        table.sort(queue, function(a,b) return a.cost > b.cost end)
		
        return false
    end
    
    --Do A*
    while table.getn(queue) > 0 do
        loopRet = AStarLoopBody()       
        
        if loopRet then
            return loopRet     
        end
    end
    
    return false
end

function SendPlatoonWithTransports(aiBrain, platoon, destination, bRequired, bSkipLastMove)

    GetMostRestrictiveLayer(platoon)
    
    local units = platoon:GetPlatoonUnits()
    
    
    # only get transports for land (or partial land) movement
    if platoon.MovementLayer == 'Land' or platoon.MovementLayer == 'Amphibious' then
    
        if platoon.MovementLayer == 'Land' then
            # if it's water, this is not valid at all
            local terrain = GetTerrainHeight(destination[1], destination[2])
            local surface = GetSurfaceHeight(destination[1], destination[2])
            if terrain < surface then
                return false
            end
        end
    
        # if we don't *need* transports, then just call GetTransports... 
        if not bRequired then
            #  if it doesn't work, tell the aiBrain we want transports and bail
            if AIUtils.GetTransports(platoon) == false then
                aiBrain.WantTransports = true
                return false
            end
        else
            # we were told that transports are the only way to get where we want to go...
            # ask for a transport every 10 seconds
            local counter = 0
            local transportsNeeded = AIUtils.GetNumTransports(units)
            local numTransportsNeeded = math.ceil( ( transportsNeeded.Small + ( transportsNeeded.Medium * 2 ) + ( transportsNeeded.Large * 4 ) ) / 10 )
            if not aiBrain.NeedTransports then
                aiBrain.NeedTransports = 0
            end
            aiBrain.NeedTransports = aiBrain.NeedTransports + numTransportsNeeded
            if aiBrain.NeedTransports > 10 then
                aiBrain.NeedTransports = 10
            end
            local bUsedTransports, overflowSm, overflowMd, overflowLg = AIUtils.GetTransports(platoon) 
            while not bUsedTransports and counter < 6 do
                # if we have overflow, dump the overflow and just send what we can
                if not bUsedTransports and overflowSm + overflowMd + overflowLg > 0 then
                    local goodunits, overflow = AIUtils.SplitTransportOverflow(units, overflowSm, overflowMd, overflowLg)
                    local numOverflow = table.getn(overflow)
                    if table.getn(goodunits) > numOverflow and numOverflow > 0 then
                        local pool = aiBrain:GetPlatoonUniquelyNamed('ArmyPool')
                        for _,v in overflow do
                            if not v:IsDead() then
                                aiBrain:AssignUnitsToPlatoon( pool, {v}, 'Unassigned', 'None' )
                            end
                        end
                        units = goodunits
                    end
                end
                bUsedTransports, overflowSm, overflowMd, overflowLg = AIUtils.GetTransports(platoon)
                if bUsedTransports then 
                    break 
                end
                counter = counter + 1				
                WaitSeconds(10)
                if not aiBrain:PlatoonExists(platoon) then
                    aiBrain.NeedTransports = aiBrain.NeedTransports - numTransportsNeeded
                    if aiBrain.NeedTransports < 0 then
                        aiBrain.NeedTransports = 0
                    end
                    return false
                end
                
                local survivors = {}
                for _,v in units do
                    if not v:IsDead() then
                        table.insert(survivors, v)
                    end
                end
                units = survivors
                
            end
            
            aiBrain.NeedTransports = aiBrain.NeedTransports - numTransportsNeeded
            if aiBrain.NeedTransports < 0 then
                aiBrain.NeedTransports = 0
            end
           
            # couldn't use transports...
            if bUsedTransports == false then
				return false
            end  
        end
        # presumably, if we're here, we've gotten transports
        # find an appropriate transport marker if it's on the map
        local transportLocation = AIUtils.AIGetClosestMarkerLocation(aiBrain, 'Transport Marker', destination[1], destination[3])
        local useGraph = 'Land'
        if not transportLocation then
            # go directly to destination, do not pass go.  This move might kill you, fyi.
            transportLocation = platoon:GetPlatoonPosition()
            useGraph = 'Air'
        end
        
		if transportLocation then
		    local minThreat = aiBrain:GetThreatAtPosition( transportLocation, 0, true )
		    if minThreat > 0 then
		        local threatTable = aiBrain:GetThreatsAroundPosition(transportLocation, 1, true, 'Overall' )
		        for threatIdx,threatEntry in threatTable do
		            if threatEntry[3] < minThreat then
                        # if it's land...
                        local terrain = GetTerrainHeight(threatEntry[1], threatEntry[2])
                        local surface = GetSurfaceHeight(threatEntry[1], threatEntry[2])
                        if terrain >= surface then
                           minThreat = threatEntry[3]
                           transportLocation = {threatEntry[1], 0, threatEntry[2]}
                       end
                    end
                end
            end
        end
		    
		# path from transport drop off to end location
		local path, reason = PlatoonGenerateSafePathTo(aiBrain, useGraph, transportLocation, destination, 200)
		# use the transport!
        AIUtils.UseTransports( units, platoon:GetSquadUnits('Scout'), transportLocation, platoon )
	    
	    # just in case we're still landing...
        for _,v in units do
            if not v:IsDead() then
                if v:IsUnitState( 'Attached' ) then
                   WaitSeconds(2)
                end
            end
        end
        
	    # check to see we're still around
	    if not platoon or not aiBrain:PlatoonExists(platoon) then
	        return false
	    end
		
		# then go to attack location
		if not path then
		    # directly
		    if not bSkipLastMove then
                platoon:AggressiveMoveToLocation(destination)
                platoon.LastAttackDestination = {destination}
            end
		else
		    # or indirectly
            # store path for future comparison
            platoon.LastAttackDestination = path

            local pathSize = table.getn(path)
            #move to destination afterwards
            for wpidx,waypointPath in path do
                if wpidx == pathSize then
                    if not bSkipLastMove then
                        platoon:AggressiveMoveToLocation(waypointPath)
                    end
                else
                    platoon:MoveToLocation(waypointPath, false)
                end
            end  		
		end
	else
		return false
    end
    
    return true
end

function AIPlatoonSquadAttackVector( aiBrain, platoon, bAggro )

    --Engine handles whether or not we can occupy our vector now, so this should always be a valid, occupiable spot.
    local attackPos = GetBestThreatTarget(aiBrain, platoon)
    
    local bNeedTransports = false
    # if no pathable attack spot found
    if not attackPos then
        # try skipping pathability
        attackPos = GetBestThreatTarget(aiBrain, platoon, true)
        bNeedTransports = true
        if not attackPos then
            platoon:StopAttack()
            return {}
        end
    end


    # avoid mountains by slowly moving away from higher areas
    GetMostRestrictiveLayer(platoon)
    if platoon.MovementLayer == 'Land' then
        local bestPos = attackPos
        local attackPosHeight = GetTerrainHeight(attackPos[1], attackPos[3])
        # if we're land
        if attackPosHeight >= GetSurfaceHeight(attackPos[1], attackPos[3]) then
            local lookAroundTable = {1,0,-2,-1,2}
            local squareRadius = (ScenarioInfo.size[1] / 16) / table.getn(lookAroundTable)
            for ix, offsetX in lookAroundTable do
                for iz, offsetZ in lookAroundTable do
                    local surf = GetSurfaceHeight( bestPos[1]+offsetX, bestPos[3]+offsetZ )
                    local terr = GetTerrainHeight( bestPos[1]+offsetX, bestPos[3]+offsetZ )
                    # is it lower land... make it our new position to continue searching around
                    if terr >= surf and terr < attackPosHeight then
                        bestPos[1] = bestPos[1] + offsetX
                        bestPos[3] = bestPos[3] + offsetZ
                        attackPosHeight = terr
                    end
                end
            end
        end
        attackPos = bestPos
    end
        
    local oldPathSize = table.getn(platoon.LastAttackDestination)
    
    # if we don't have an old path or our old destination and new destination are different
    if oldPathSize == 0 or attackPos[1] != platoon.LastAttackDestination[oldPathSize][1] or
    attackPos[3] != platoon.LastAttackDestination[oldPathSize][3] then
        
        GetMostRestrictiveLayer(platoon)
        # check if we can path to here safely... give a large threat weight to sort by threat first
        local path, reason = PlatoonGenerateSafePathTo(aiBrain, platoon.MovementLayer, platoon:GetPlatoonPosition(), attackPos, platoon.PlatoonData.NodeWeight or 10 )
    
        # clear command queue
        platoon:Stop()    
   
        local usedTransports = false
        local position = platoon:GetPlatoonPosition()
        if (not path and reason == 'NoPath') or bNeedTransports then
            usedTransports = SendPlatoonWithTransports(aiBrain, platoon, attackPos, true)
        # Require transports over 500 away
        elseif VDist2Sq( position[1], position[3], attackPos[1], attackPos[3] ) > 512*512 then
            usedTransports = SendPlatoonWithTransports(aiBrain, platoon, attackPos, true)
        # use if possible at 250
        elseif VDist2Sq( position[1], position[3], attackPos[1], attackPos[3] ) > 256*256 then
            usedTransports = SendPlatoonWithTransports(aiBrain, platoon, attackPos, false)
        end
        
        if not usedTransports then
            if not path then
                if reason == 'NoStartNode' or reason == 'NoEndNode' then
                    --Couldn't find a valid pathing node. Just use shortest path.
                    platoon:AggressiveMoveToLocation(attackPos)
                end
                # force reevaluation
                platoon.LastAttackDestination = {attackPos}
            else
                local pathSize = table.getn(path)
                # store path
                platoon.LastAttackDestination = path
                # move to new location
                for wpidx,waypointPath in path do
                    if wpidx == pathSize or bAggro then
                        platoon:AggressiveMoveToLocation(waypointPath)
                    else
                        platoon:MoveToLocation(waypointPath, false)
                    end
                end   
            end
        end
    end 
    
    # return current command queue 
    local cmd = {}
    for k,v in platoon:GetPlatoonUnits() do
        if not v:IsDead() then
            local unitCmdQ = v:GetCommandQueue()
            for cmdIdx,cmdVal in unitCmdQ do
                table.insert(cmd, cmdVal)
                break
            end
        end
    end
    return cmd
end

end