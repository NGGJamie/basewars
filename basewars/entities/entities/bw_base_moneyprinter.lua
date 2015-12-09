local fontName = "BaseWars.MoneyPrinter"

ENT.Base = "bw_base_electronics"

ENT.Model = "models/props_lab/reciever01a.mdl"
ENT.Skin = 0

ENT.Capacity 		= 10000
ENT.Money 			= 0
ENT.Paper 			= 1000
ENT.PrintInterval 	= 1
ENT.PrintAmount		= 50

ENT.PrintName = "Base Money Printer"

local Clamp = math.Clamp
local function GSAT(name, var, min, max)

	ENT["Get" .. name] = function(self)

		if CLIENT then
			
			local str = self:GetNWString("printer_" .. name:lower(),"")

			return tonumber(str) or str

		end

		return self[name]

	end

	if CLIENT then return end

	ENT["Set" .. name] = function(self, var)

		if min and max then
			
			var = Clamp(tonumber(var) or 0, self[min] or min, self[max] or max)

		end

		self[name] = var
		self:SetNWString("printer_" .. name:lower(),tostring(var))

	end

	ENT["Add" .. name] = function(self, var)

			self["Set" .. name](self, self["Get" .. name](self) + var)

	end

	ENT["Take" .. name] = function(self, var)

		self["Set" .. name](self, self["Get" .. name](self) - var)

	end

end

GSAT("Capacity", "Capacity")
GSAT("Money", "Money", 0, "Capacity")
GSAT("Paper", "Paper", 0, 1000)

if SERVER then

	AddCSLuaFile()

	function ENT:Init()

		self.time = CurTime()
		self.time_p = CurTime()

		self:SetCapacity(self.Capacity)
		self:SetPaper(100)

		self:SetHealth(100)

		self.rtb = 0

	end

	function ENT:ThinkFunc()

		if self.Disabled then return end
		local added

		if CurTime() >= self.PrintInterval + self.time and self:GetPaper() > 0 then
			
			local m = self:GetMoney()
			self:AddMoney(self.PrintAmount)
			self.time = CurTime()
			added = m ~= self:GetMoney()

		end

		if CurTime() >= self.PrintInterval * 2 + self.time_p and added then
			
			self.time_p = CurTime()
			self:TakePaper(1)

		end	

	end

	function ENT:PlayerTakeMoney(ply)

		local money = self:GetMoney()
		self:TakeMoney(money)

		ply:SetMoney(ply:GetMoney() + money)
		ply:EmitSound("mvm/mvm_money_pickup.wav")

	end

	function ENT:UseFuncBypass(activator, caller, usetype, value)

		if self.Disabled then return end

		if activator:IsPlayer() and caller:IsPlayer() and self:GetMoney() > 0 then
			
			self:PlayerTakeMoney(activator)

		end

	end

	function ENT:SetDisabled(a)

		self.Disabled = a and true or false
		self:SetNWBool("printer_disabled",a and true or false)

	end
	
else

	surface.CreateFont(fontName, {

		font = "Roboto",
		size = 20,
		weight = 800,

	})

	surface.CreateFont(fontName .. ".Huge", {

		font = "Roboto",
		size = 64,
		weight = 800,

	})


	surface.CreateFont(fontName .. ".Big", {

		font = "Roboto",
		size = 32,
		weight = 800,

	})

	surface.CreateFont(fontName .. ".MedBig", {

		font = "Roboto",
		size = 24,
		weight = 800,

	})

	surface.CreateFont(fontName .. ".Med", {

		font = "Roboto",
		size = 18,
		weight = 800,

	})

	function ENT:DrawDisplay(pos, ang, scale)

		local w, h = 216 * 2, 136 * 2
		local disabled = self:GetNWBool("printer_disabled")

		draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0))
		if disabled then
			
			draw.DrawText("This printer has been", fontName, w / 2, h / 2 - 48, Color(255,255,255), TEXT_ALIGN_CENTER)
			draw.DrawText("DISABLED", fontName .. ".Huge", w / 2, h / 2 - 32, Color(255,0,0), TEXT_ALIGN_CENTER)

		return end
		draw.DrawText(self.PrintName, fontName, w / 2, 4, Color(255,255,255), TEXT_ALIGN_CENTER)

		if disabled then return end

		draw.RoundedBox(0, 0, 30, w, 1, Color(255, 255, 255))
		draw.DrawText("LEVEL: 0", fontName .. ".Big", 4, 32, Color(255,255,255), TEXT_ALIGN_LEFT)
		draw.RoundedBox(0, 0, 68, w, 1, Color(255, 255, 255))

		draw.DrawText("CASH", fontName .. ".Big", 4, 72, Color(255,255,255), TEXT_ALIGN_LEFT)
		draw.RoundedBox(0, 0, 72 + 32, w, 1, Color(255, 255, 255))
		
		local boxw = 128 - 40
		draw.RoundedBox(0, boxw, 74, w - boxw * 2.75, 24, Color(255, 255, 255))

		local money = tonumber(self:GetMoney()) or 0
		local cap = tonumber(self:GetCapacity()) or 0
		if cap > 0 and cap ~= math.huge then
			local mc = money / cap
			local ww = math.floor(w - boxw * 2.75 - 4)
			local www = ww * mc

			draw.RoundedBox(0, boxw + 188, 76, www - ww, 24 - 4, Color(0, 0, 0))
		end

		local text = "£" .. BaseWars.NumberFormat(money)
		local font = fontName .. ".Big"
		if #text > 10 then
			
			font = fontName .. ".MedBig"

		end
		if #text > 14 then
			
			font = fontName .. ".Med"

		end
		local fh = draw.GetFontHeight(font)

		draw.DrawText(text, font,
			w - 4, (font == fontName .. ".Big" and 71 or 70 + fh / 4), Color(255, 255, 255), TEXT_ALIGN_RIGHT)

		local paper = math.floor(self:GetPaper() * 60)
		draw.DrawText("Paper: " .. paper .. " sheets", fontName .. ".MedBig", 4, 84 + 24, Color(255,255,255), TEXT_ALIGN_LEFT)

	end

	function ENT:Calc3D2DParams()

		local pos = self:GetPos()
		local ang = self:GetAngles()

		pos = pos + ang:Up() * 3.08
		pos = pos + ang:Forward() * -7.35
		pos = pos + ang:Right() * 10.82

		ang:RotateAroundAxis(ang:Up(), 90)

		return pos, ang, 0.1 / 2

	end

	function ENT:Draw()

		self:DrawModel()

		local pos, ang, scale = self:Calc3D2DParams()

		cam.Start3D2D(pos, ang, scale) 
			pcall(self.DrawDisplay, self, pos, ang, scale)
		cam.End3D2D()

	end

end
