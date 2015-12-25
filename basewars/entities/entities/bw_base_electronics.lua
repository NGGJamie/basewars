AddCSLuaFile()

ENT.Base = "bw_base"
ENT.Type = "anim"
ENT.PrintName = "Base Electricals"

ENT.Model = "models/props_c17/metalPot002a.mdl"
ENT.Skin = 0

ENT.IsElectronic = true
ENT.PowerRequired = 5
ENT.PowerCapacity = 1000

function ENT:DrainPower(val)

	if not self:IsPowered(val) then return false end

	self:SetPower(self:GetPower() - (val or self.PowerRequired))
	
	return true
	
end

function ENT:IsPowered(val)

	return self:GetPower() >= (val or self.PowerRequired)
	
end

if SERVER then

	function ENT:Think()

		if self:IsPowered() and self:BadlyDamaged() and math.random(0, 11) == 0 then
			
			self:Spark()

		end
	
		if self:WaterLevel() > 0 and not self:GetWaterProof() then

			if not self.FirstTime and self:Health() > 25 then
				
				self:SetHealth(25)
				self:Spark()
				
				self.FirstTime = true

			end
			
			if self.rtb == 2 then
				
				self.rtb = 0
				self:TakeDamage(1)

			else

				self.rtb = self.rtb + 1

			end

		else
			
			self.FirstTime = false
			
		end
		
		if not self:DrainPower() or self:BadlyDamaged() then return end

		self:ThinkFunc()

	end
	
end
