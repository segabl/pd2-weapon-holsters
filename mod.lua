WeaponHolsters = {
	-- Align places for specific hold types (default is back)
	hold_align_names = {
		pistol = "hips_right",
		akimbo_pistol = "hips_right",
		bow = "bow"
	},
	-- Align places for specific weapons
	align_overrides = {
		frankish_crew = "crossbow",
		arblast_crew = "crossbow",
		m134_crew = "minigun"
	}
}

-- Add new align places
function WeaponHolsters.define_align_places(inventory)
	inventory._align_places.back = {
		on_body = true,
		obj3d_name = Idstring("BackPack1"),
		local_rot = Rotation(270, 0, 90),
		local_pos = Vector3(-15, 5, 10)
	}
	inventory._align_places.hips_right = {
		on_body = true,
		obj3d_name = Idstring("Hips"),
		local_rot = Rotation(170, 0, 0),
		local_pos = Vector3(-20, 5, 0),
	}
	inventory._align_places.hips_left = {
		on_body = true,
		obj3d_name = Idstring("Hips"),
		local_rot = Rotation(190, 0, 0),
		local_pos = Vector3(20, 5, 0)
	}
	-- Specialized align places
	inventory._align_places.bow = {
		on_body = true,
		obj3d_name = Idstring("BackPack1"),
		local_rot = Rotation(90, 0, 80),
		local_pos = Vector3(-20, 10, 10)
	}
	inventory._align_places.crossbow = {
		on_body = true,
		obj3d_name = Idstring("BackPack1"),
		local_rot = Rotation(0, 0, 0),
		local_pos = Vector3(-15, -20, 5)
	}
	inventory._align_places.minigun = {
		on_body = true,
		obj3d_name = Idstring("BackPack1"),
		local_rot = Rotation(270, 0, 90),
		local_pos = Vector3(-40, 0, 5)
	}

	-- Where to align the scond gun of akimbo weapons
	inventory._align_places.right_hand.second_gun = inventory._align_places.left_hand
	inventory._align_places.hips_right.second_gun = inventory._align_places.hips_left

	-- Mark as modified
	inventory._has_extra_align_places = true
end

-- Turn off gadgets when holstering weapons
function WeaponHolsters.turn_off_gadgets(inventory, selection_index, is_equip)
	if is_equip then
		return
	end

	if not inventory._has_extra_align_places then
		return
	end

	local selection = inventory._available_selections[selection_index]
	local unit = selection.unit
	if selection.use_data.unequip.align_place then
		if unit:base().gadget_off then
			unit:base():gadget_off()
		end
	end
end

-- Adjust weapon position/rotation and account for akimbo
function WeaponHolsters.adjust_positioning(inventory, unit, align_place)
	if not inventory._has_extra_align_places then
		return
	end

	unit:set_local_position(align_place.local_pos or Vector3())
	unit:set_local_rotation(align_place.local_rot or Rotation())
	if unit:base()._second_gun then
		inventory:_link_weapon(unit:base()._second_gun, align_place.second_gun or align_place)
	end
end


if RequiredScript == "lib/units/beings/player/huskplayerinventory" then

	Hooks:PostHook(HuskPlayerInventory, "init", "weaponholsters_init", WeaponHolsters.define_align_places)
	Hooks:PostHook(HuskPlayerInventory, "_place_selection", "weaponholsters_place_selection", WeaponHolsters.turn_off_gadgets)
	Hooks:PostHook(HuskPlayerInventory, "_link_weapon", "weaponholsters_link_weapon", WeaponHolsters.adjust_positioning)

elseif RequiredScript == "lib/units/weapons/newnpcraycastweaponbase" then

	-- Check align place overrides
	Hooks:PostHook(NewNPCRaycastWeaponBase, "_create_use_setups", "weaponholsters_create_use_setups", function (self)
		local new_align_place = WeaponHolsters.align_overrides[self._name_id] or WeaponHolsters.hold_align_names[self:weapon_tweak_data().hold]
		self._use_data.player.unequip.align_place = new_align_place or self._use_data.player.unequip.align_place
	end)

	-- Remove back align place for non player weapons
	Hooks:PostHook(NPCRaycastWeaponBase, "_create_use_setups", "weaponholsters_create_use_setups", function (self)
		self._use_data.player.unequip.align_place = nil
	end)

end
