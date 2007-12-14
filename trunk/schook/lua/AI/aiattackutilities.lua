do

function PlatoonGenerateSafePathTo(aiBrain, platoonLayer, start, destination, optThreatWeight, optMaxMarkerDist)   
        
    local location = start
    optMaxMarkerDist = optMaxMarkerDist or 250
    optThreatWeight = optThreatWeight or 1
    local finalPath = {}
	
	if VDist2( start[1], start[3], destination[1], destination[3] ) < 20 then
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
    local path = GeneratePath(aiBrain, startNode, endNode, ThreatTable[platoonLayer], optThreatWeight)
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
                        if terrain - surface > 0  then
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

end