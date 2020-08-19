--[[
	Script: Poo & Pee
	Version: 1.0
	Created by DidVaitel (http://steamcommunity.com/profiles/76561198108670811)
]]

AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName = "Poop"
ENT.Author = "DidVaitel"
ENT.Contact = "contact@gmodhub.com"
ENT.Category = "DidVaitel Entities"

ENT.Editable = true
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- We do NOT want to execute anything below on CLIENT
if ( CLIENT ) then return end

function ENT:Initialize()
	
	self:SetModel(table.Random({ "models/poo/bpoo.mdl", "models/poo/curlygpoo.mdl" }))
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:PhysWake()

	local size = math.random(1, 6)
	self:SetCollisionBounds( Vector( -size, -size, -size ), Vector( size, size, size ) )
	self:SetModelScale(size)
	self:GetPhysicsObject():SetMass(5000)
end

function ENT:Use(activator, caller)

	self:Remove()

	if ( activator:IsPlayer() ) then

		activator:EmitSound("vo/sandwicheat09.ogg", 100, 100)

		-- Give the collecting player some free health || Takes the collecting player health
		local health = activator:Health()

		if ( math.random(1, 4) == 2 ) then
			if health <= 10 then
				activator:Kill()
			else
				activator:SetHealth(health - 10)
			end
			return
		end

		activator:SetHealth( health + 5 )

	end

end

function ENT:PhysicsCollide( data, physobj )

	-- Play sound on bounce
	if ( data.Speed > 60 && data.DeltaTime > 0.2 ) then

		local pitch = 160
		sound.Play( "player/footsteps/mud" .. math.random( 1, 4 ) .. ".wav", self:GetPos(), 75, math.random( pitch - 10, pitch + 10 ), math.Clamp( data.Speed / 150, 0, 1 ) )

	end

	-- More realistic bounce
	local LastSpeed = math.max( data.OurOldVelocity:Length(), data.Speed )
	local NewVelocity = physobj:GetVelocity()
	NewVelocity:Normalize()

	LastSpeed = math.max( NewVelocity:Length(), LastSpeed )
	local TargetVelocity = NewVelocity * LastSpeed * 0.2
	physobj:SetVelocity( TargetVelocity )

	-- Shit Decal
	local spos = self:GetPos()
    local trs = util.TraceLine({start=spos + Vector(0,0,64), endpos=spos + Vector(0,0,-128), filter=self})
	util.Decal("BeerSplash", trs.HitPos + trs.HitNormal, trs.HitPos - trs.HitNormal)     

	local effectdata = EffectData()
	effectdata:SetOrigin( self:GetPos() )
	util.Effect( "WheelDust", effectdata ) 
end

function ENT:OnTakeDamage( dmginfo )

	self:TakePhysicsDamage( dmginfo )

end