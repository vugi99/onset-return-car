

local turn_speed = 510
local last_veh_supported = 40
local blacklisted_vehs = {
    10,
    20,
    26,
    30,
    31,
    33,
    34
}


local car_returned = false
local returning_car = false
local pressingr = false
local pressingl = false

local function IsVehicleBlacklisted(model)
   for i, v in ipairs(blacklisted_vehs) do
      if model == v then
         return true
      end
   end
   return false
end

local function check_car_returned()
   local veh = GetPlayerVehicle(GetPlayerId())
   if (veh ~= 0 and GetVehicleDriver(veh) == GetPlayerId()) then
      local model = GetVehicleModel(veh)
      if (not IsVehicleBlacklisted(model) and model <= last_veh_supported and GetVehicleHealth(veh) > 0) then
         local rx, ry, rz = GetVehicleRotation(veh)
         local vx, vy, vz = GetVehicleVelocity(veh)
         if vx < 0 then
            vx = vx*-1
         end
         if vy < 0 then
            vy = vy*-1
         end
         if vz < 0 then
            vz = vz*-1
         end
         local vel = vx + vy + vz
         local IsInAir = IsVehicleInAir(veh)
         if ((rz < -80 and vel < 1 and IsInAir) or (rz > 80 and vel < 1 and IsVehicleInAir)) then
            car_returned = true
         else
            car_returned = false
         end
      else
         car_returned = false
      end
   else
      car_returned = false
      returning_car = false
   end
end

AddEvent("OnPackageStart", function()
    CreateTimer(check_car_returned, 500)
end)

AddEvent("OnGameTick", function(ds)
    if GetInputAxisValue("MoveRight") == 1.0 then
       pressingr = true
       pressingl = false
    end
    if GetInputAxisValue("MoveRight") == -1.0 then
       pressingr = false
       pressingl = true
    end
    if GetInputAxisValue("MoveRight") == 0 then
       pressingr = false
       pressingl = false
    end
    local veh = GetPlayerVehicle(GetPlayerId())
    if veh ~= 0 then
      local rx, ry, rz = GetVehicleRotation(veh)
      if (car_returned or (returning_car and (rz > 30 or rz < -30))) then
         if (GetVehicleDriver(veh) == GetPlayerId()) then
            local vehsk = GetVehicleSkeletalMeshComponent(veh)
            local fx,fy,fz = GetVehicleForwardVector(veh)
            local fx2 = fx*ds
            local fy2 = fy*ds
            local fz2 = fz*ds
            local mult_angle = 13
            local steer_l = GetVehicleWheelSteerAngle(veh, 0)/75
            local steer_r = GetVehicleWheelSteerAngle(veh, 1)/75
            if not (pressingr and pressingl) then
               if pressingr then
                  vehsk:SetPhysicsAngularVelocityInDegrees(FVector(fx2*-1*turn_speed*mult_angle*steer_r,fy2*-1*turn_speed*mult_angle*steer_r,fz2*-1*turn_speed*mult_angle*steer_r),false)
                  returning_car = true
               end
               if pressingl then
                  vehsk:SetPhysicsAngularVelocityInDegrees(FVector(fx2*turn_speed*mult_angle*steer_l*-1,fy2*turn_speed*mult_angle*steer_l*-1,fz2*turn_speed*mult_angle*steer_l*-1),false)
                  returning_car = true
               end
            end
            if (not pressingl and not pressingr) then
               returning_car = false
            end
         end
      end
   end
end)