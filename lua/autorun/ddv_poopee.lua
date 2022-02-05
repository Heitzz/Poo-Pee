--[[
	Script: Poo & Pee
	Version: 1.0
	Created by DidVaitel (http://steamcommunity.com/profiles/76561198108670811)
]]

if ( CLIENT ) then

    local function CollideCallback(particle, hitpos, normal)

        particle:SetAngleVelocity( Angle(0, 0, 0) )

        local angle = normal:Angle()
        angle:RotateAroundAxis( normal, particle:GetAngles().y )
        particle:SetAngles( angle )

        particle:SetBounce( 1 )
        particle:SetVelocity( Vector( 0, 0, -100 ) )
        particle:SetGravity( Vector( 0, 0, -100 ) )

        particle:SetLifeTime( 0 )
        particle:SetDieTime( 30 )

        particle:SetStartSize( 10 )
        particle:SetEndSize( 0 )

        particle:SetStartAlpha( 255 )
        particle:SetEndAlpha( 0 )
    end

    net.Receive('DDV.MakePee', function()

        local ply = net.ReadEntity()

        if ( !IsValid( ply ) ) then return end

        local center = ply:GetPos() + Vector( 0, 0, 32 )
        local emitter = ParticleEmitter(center)

        // Calculates pee time
        for i = 1, (3 * 10) do
            timer.Simple(i/100, function()

                if ( !IsValid( ply ) ) then return end

                local part = emitter:Add('sprites/orangecore2', center)
                if part then
                    part:SetVelocity( ply:GetAimVector() * 1000 + Vector( math.random(-50,50), math.random(-50,50), 0 ) )
                    part:SetDieTime( 30 )
                    part:SetLifeTime( 1 )
                    part:SetStartSize( 10 )
                    part:SetAirResistance( 100 )
                    part:SetRoll( math.Rand(0, 360) )
                    part:SetRollDelta( math.Rand(-200, 200) )
                    part:SetGravity( Vector( 0, 0, -600 ) )
                    part:SetCollideCallback( CollideCallback )
                    part:SetCollide( true )
                    part:SetEndSize( 0 )
                end

            end)
        end

        // Stop particle emitter
        timer.Simple(3, function()
            emitter:Finish()
        end)

    end)

elseif ( SERVER ) then

    resource.AddWorkshop("2202614385") // Auto Workshop DL
    util.AddNetworkString("DDV.MakePee")

    function Poop( ply, command, arguments )

        -- We don't support this command from dedicated server console
        if ( !IsValid( ply ) ) then return end

        -- We don't need pee from dead players
	    if ( !ply:Alive() ) then return end

        -- Let's create a poop
        local poop = ents.Create("ddv_poop")
        poop:SetPos( ply:GetPos() + Vector(0, 0, 32) )
        poop:Spawn()

        -- Emit cool sound and create remove timer
        ply:EmitSound( "ambient/levels/canals/swamp_bird2.wav", 50, 80 )
        timer.Simple(30, function() if poop:IsValid() then poop:Remove() end end)

        -- Luck check
        if ( ply.NextPoo != nil && ply.NextPoo >= CurTime() && (math.random(1, 5) == 5) ) then ply:Kill() return end
        ply.NextPoo = CurTime() + 10
    end
    concommand.Add( "poop", Poop, nil, "Do poop" )

    function Piss( ply, command, arguments )

        -- We don't support this command from dedicated server console
        if ( !IsValid( ply ) ) then return end

        -- We don't need pee from dead players
	    if ( !ply:Alive() ) then return end

        -- No more pee :(
        if ply.NextPee != nil && ply.NextPee >= CurTime() then return end

        -- Send Pee
        net.Start("DDV.MakePee")
            net.WriteEntity(ply)
        net.Broadcast()

        ply.NextPee = CurTime() + 30
    end
    concommand.Add( "piss", Piss, nil, "Do pee" )

end
