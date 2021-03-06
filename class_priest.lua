if select(2, UnitClass('player')) ~= "PRIEST" then return end

PREC.enable_for_class = true;

PREC.default_options.meters = {

	sw_pain = true,
	vampiric_touch = true,
	devouring_plague = true,
};

PREC.default_options.warnings = {

	fort = true,
	inner_fire = true,
	shadowform = true,
	bad_weapon = true, -- fishing pole, lance
};

PREC.rotations = {
	sp505 = {
		name = "Shadow Priest (5.0.5)",
		p1 = { which="sw_pain",		bind="",	who="any", label="1" },
		p2 = { which="vampiric_touch",	bind="",	who="any", label="3" },
		p3 = { which="plague_three",	bind="",	who="any", label="4" },
		p4 = { which="mind_blast",	bind="",	who="any", label="2" },
		p5 = { which="surge_spike",	bind="",	who="any", label="6" },
		p6 = { which="sw_death",	bind="",	who="any", label="5" },
		p7 = { which="mind_flay",	bind="",	who="any", label="8" },
		p8 = {},
		p9 = {},
		p10 = {},
		p11 = {},
		p12 = {},
	},
	sp510 = {
		name = "Shadow Priest (5.1.0)",
		p1 = { which="plague_three",	bind="",	who="any", label="4" },
		p2 = { which="mind_blast",	bind="",	who="any", label="2" },
		p3 = { which="sw_death",	bind="",	who="any", label="5" },
		p4 = { which="halo",		bind="",	who="any", label="9" },
		p5 = { which="surge_spike",	bind="",	who="any", label="6" },
		p6 = { which="vampiric_touch",	bind="",	who="any", label="3" },
		p7 = { which="sw_pain",		bind="",	who="any", label="1" },
		p8 = { which="mind_flay",	bind="",	who="any", label="8" },
		p9 = {},
		p10 = {},
		p11 = {},
		p12 = {},
	},
};

PREC.default_options.priorities = PREC.rotations.sp505;

PREC.abilities = {
	sw_pain = {
		icon = "spell_shadow_shadowwordpain",
		spell = "Shadow Word: Pain",
		debuff = "Shadow Word: Pain",
		delay_recast_for = 1,
	},
	mind_blast = {
		icon = "spell_shadow_unholyfrenzy",
		spell = "Mind Blast",
		delay_recast_for = 4,
	},
	vampiric_touch = {
		icon = "spell_holy_stoicism",
		spell = "Vampiric Touch",
		debuff = "Vampiric Touch",
		delay_recast_for = 1,
	},
	devouring_plague = {
		icon = "spell_shadow_devouringplague",
		spell = "Devouring Plague",
	},
	sw_death = {
		icon = "spell_shadow_demonicfortitude",
		spell = "Shadow Word: Death",
		label = "Shadow Word: Death (under 25%)",
	},
	archangel = {
		icon = "ability_priest_archangel",
		spell = "Archangel",
		havebuff = "Dark Evangelism",
		buff_stacks = 5,
		label = "Archangel (5 stacks)",
	},
	archangel_any = {
		icon = "ability_priest_archangel",
		spell = "Archangel",
		label = "Archangel (1 stack)",
	},
	shadowfiend = {
		icon = "spell_shadow_shadowfiend",
		spell = "Shadowfiend",
		-- only at 80% mana
	},
	mind_flay = {
		icon = "spell_shadow_siphonmana",
		spell = "Mind Flay",
	},
	plague_three = {
		icon = "spell_shadow_devouringplague",
		spell = "Devouring Plague",
		label = "Devouring Plague (w/ 3 Orbs)",
	},
	surge_spike = {
		icon = "spell_priest_mindspike",
		spell = "Mind Spike",
		havebuff = "Surge of Darkness",
	},
	halo = {
		icon = "ability_priest_halo_shadow",
		spell = "Halo",
	},
};

PREC.meterinfo = {
	sw_pain = {
		icon = "spell_shadow_shadowwordpain",
		debuff = "Shadow Word: Pain",
		color = "green",
	},
	vampiric_touch = {
		icon = "spell_holy_stoicism",
		debuff = "Vampiric Touch",
		color = "green",
	},
	devouring_plague = {
		icon = "spell_shadow_devouringplague",
		debuff = "Devouring Plague",
		color = "green",
	},
}

PREC.warningdefs = {
	fort = {
		title = "Buffed: Fortitude",
		icon = [[Interface\Icons\spell_holy_wordfortitude]],
		has_buff = "Power Word: Fortitude",
	},
	inner_fire = {
		title = "Buffed: Inner Fire",
		icon = [[Interface\Icons\spell_holy_innerfire]],
		has_buff = "Inner Fire",
	},
	shadowform = {
		title = "Shadowform",
		icon = [[Interface\Icons\spell_shadow_shadowform]],
		has_buff = "Shadowform",
		scale = 2,
	},
	bad_weapon = {
		title = "Bad Weapon Equipped",
		icon = [[Interface\Icons\inv_weapon_shortblade_05]],
		--not_implemented = true,
	}
};

PREC.state.simulate_focus_loss_until = 0;
PREC.state.no_shots_until = 0;
PREC.state.delay_spell_until = {};

function PREC.OnCombatLog(...)

	local ts, event, hideCaster, sourceGuid, sourceName, sourceFlags, sourceFlags2, destGuid, destName, destFlags, destFlasg2, spellId, spellName, spellSchool = ...;

	local srcUs = false;
	local ourGuid = UnitGUID("player");
	local tarGuid = UnitGUID("target");
	if (sourceGuid == ourGuid) then srcUs = true; end

	if (false and (srcUs or sourceGuid == tarGuid)) then
		local dest = destName;
		if (not dest) then dest = "?"; end
		local src = sourceName;
		if (not src) then src = "?"; end
		local spell = spellName;
		if (not spell) then spell = "?"; end

		print(string.format("%s (%s -> %s) %s", event, src, dest, spell));
	end
end

function PREC.OnSpellCastSent(...)

	local unit, spell, rank, target = ...;


	--
	-- spells with cast time need to delay all others
	--

	if (unit == "player") then
		local castTime = PREC.SpellCastTime(spell);

		if (castTime) then

			PREC.state.no_shots_until = GetTime() + (castTime / 1000);

			-- supress this spell for cast time + cooldown, since
			-- we know it has a cooldown and we're casting it now.
			-- we do the cooldown calc in the update function since
			-- we can't get cooldown until cast has succeeded
			PREC.state.delay_spell_until[spell] = PREC.state.no_shots_until;
		end
	end
end


--
-- special event handlers for updating channeled spell status
--

function PREC.event_handlers.UNIT_SPELLCAST_CHANNEL_START(unit, spellName, spellRank, lineID, spellID)

	local _,_,_,_,_,endTime = UnitChannelInfo("player");
	if (endTime) then
		PREC.state.no_shots_until = endTime / 1000;
	else
		PREC.state.no_shots_until = 0;
	end
end

function PREC.event_handlers.UNIT_SPELLCAST_CHANNEL_UPDATE(unit, spellName, spellRank, lineID, spellID)

	local _,_,_,_,_,endTime = UnitChannelInfo("player");
	if (endTime) then
		PREC.state.no_shots_until = endTime / 1000;
	else
		PREC.state.no_shots_until = 0;
	end
end

function PREC.event_handlers.UNIT_SPELLCAST_CHANNEL_STOP(unit, spellName, spellRank, lineID, spellID)

	PREC.state.no_shots_until = 0;
end


function PREC.GetWarningLabel(ret)

	ret.show_label = false;

	--
	-- range warning
	--

	local inShotRange = IsSpellInRange("Mind Sear");

	if ((ret.active_shots > 0) and ret.has_viable_target) then

		if (not (inShotRange == 1)) then

			ret.show_label = true;
			ret.label = 'Too Far';
			ret.label_mode = 'warning';
			return;
		end
	end


	--
	-- mana warning
	--

	local cur_mana = UnitPower("player", 0);
	local max_mana = UnitPowerMax("player", 0);
	local mana_percent = 100 * cur_mana / max_mana;

	if (mana_percent < 10) then

		ret.show_label = true;
		ret.label = string.format('Mana Low (%d%%)', mana_percent);
		ret.label_mode = 'mana';
		return;
	end

end

--
-- ################################################## Warnings ##################################################
--

--function PREC.warningdefs.no_pet.func(info)
--end

function PREC.warningdefs.bad_weapon.func(info)

	local itemId = GetInventoryItemID("player", 16);

	if (not itemId) then return info; end

	local _, _, _, level, _, type, subtype = GetItemInfo(itemId);

	if (level) then
		if (level < 200) then info.show = true; end
	end

	if (type == "Weapon" and subtype == "Daggers"		) then return info; end
	if (type == "Weapon" and subtype == "One-Handed Maces"	) then return info; end
	if (type == "Weapon" and subtype == "Staves"		) then return info; end
	if (type == "Weapon" and subtype == "Wands"		) then return info; end

	info.show = true;
end

--
-- ################################################## Meters ##################################################
--

--function PREC.meterinfo.trap_set.func(info)
--end


--
-- ################################################## Shots ##################################################
--

function PREC.abilities.sw_death.func(t, now, waitmana)

	local current = UnitHealth("target");
	local max = UnitHealthMax("target");

	-- no target?
	if (max == 0) then
		return {
			hide_now = true,
		};
	end

	-- over 25%?
	if (current / max > 0.25) then
		return {
			hide_now = true,
		};
	end

	return {
		t = t,
		waitmana = waitmana,
	};
end

function PREC.abilities.plague_three.func(t, now, waitmana)

	local orbs = UnitPower("player", 13);
	if (orbs < 3) then
		return {
			hide_now = true,
		};
	end

	return {
		t = t,
		waitmana = waitmana,
	};
end
