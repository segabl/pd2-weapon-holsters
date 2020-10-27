WeaponHolsters = {
  hold_align_names = {
    pistol = "hips_right",
    akimbo_pistol = "hips_right",
    bow = "bow"
  },
  align_overrides = {
    frankish_crew = "crossbow",
    arblast_crew = "crossbow",
    m134_crew = "minigun"
  },
  align_places = {
    -- Generic align places
    back = {
      on_body = true,
      obj3d_name = Idstring("BackPack1"),
      local_rot = Rotation(270, 0, 90),
      local_pos = Vector3(-15, 5, 10)
    },
    hips_right = {
      on_body = true,
      obj3d_name = Idstring("Hips"),
      local_rot = Rotation(170, 0, 0),
      local_pos = Vector3(-20, 5, 0)
    },
    hips_left = {
      on_body = true,
      obj3d_name = Idstring("Hips"),
      local_rot = Rotation(190, 0, 0),
      local_pos = Vector3(20, 5, 0)
    },
    
    -- Specialized align places
    crossbow = {
      on_body = true,
      obj3d_name = Idstring("BackPack1"),
      local_rot = Rotation(0, 0, 0),
      local_pos = Vector3(-15, -20, 5)
    },
    bow = {
      on_body = true,
      obj3d_name = Idstring("BackPack1"),
      local_rot = Rotation(90, 0, 80),
      local_pos = Vector3(-20, 10, 10)
    },
    minigun = {
      on_body = true,
      obj3d_name = Idstring("BackPack1"),
      local_rot = Rotation(270, 0, 90),
      local_pos = Vector3(-40, 0, 5)
    }
  }
}

if RequiredScript == "lib/units/beings/player/huskplayerinventory" then

  -- Add new align places
  Hooks:PostHook(HuskPlayerInventory, "init", "weaponholsters_init", function (self)

    for k, v in pairs(WeaponHolsters.align_places) do
      self._align_places[k] = v
    end

  end)

  -- Turn off gadgets when holstering weapons
  Hooks:PostHook(HuskPlayerInventory, "_place_selection", "weaponholsters_place_selection", function (self, selection_index, is_equip)

    if is_equip then
      return
    end
    local unit = self._available_selections[selection_index].unit
    if unit:base().gadget_off then
      unit:base():gadget_off()
    end

  end)

  -- Adjust weapon position/rotation and account for akimbo
  Hooks:PostHook(HuskPlayerInventory, "_link_weapon", "weaponholsters_link_weapon", function (self, unit, align_place)

    unit:set_local_position(align_place.local_pos or Vector3())
    unit:set_local_rotation(align_place.local_rot or Rotation())
    if unit:base()._second_gun then
      self:_link_weapon(unit:base()._second_gun, align_place == self._align_places.hips_right and self._align_places.hips_left or self._align_places.left_hand or align_place)
    end

  end)

end


if RequiredScript == "lib/units/weapons/raycastweaponbase" then

  -- Use different align place for pistols
  Hooks:PostHook(RaycastWeaponBase, "_create_use_setups", "weaponholsters_create_use_setups", function (self)
    
    local w_tweak = tweak_data.weapon[self._name_id]
    if not w_tweak then
      return
    end
    self._use_data.player.unequip.align_place = WeaponHolsters.align_overrides[self._name_id] or WeaponHolsters.hold_align_names[w_tweak.hold] or self._use_data.player.unequip.align_place
    
  end)

end