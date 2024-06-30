local mondrian = {
    object_type = "Joker",
    name = "cry-mondrian",
    key = "mondrian",
    pos = {x = 0, y = 0},
    config = {extra = {extra = 0.25, x_mult = 1}},
    loc_txt = {
    name = 'Mondrian',
    text = {
                "This Joker gains {X:mult,C:white} X#1# {} Mult",
                "If no {C:attention}discards{} were used this round",
                "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)"
           }
    },
    rarity = 2,
    cost = 7,
    discovered = true,
    perishable_compat = false,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.extra, center.ability.extra.x_mult}}
    end,
    atlas = "mondrian",
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and (card.ability.extra.x_mult > 1) and not context.before and not context.after then
            return {
                message = localize{type='variable',key='a_xmult',vars={card.ability.extra.x_mult}},
                Xmult_mod = card.ability.extra.x_mult
            }
        end
        if context.end_of_round and G.GAME.current_round.discards_used == 0 and not context.blueprint and not context.individual and not context.repetition then
            card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.extra
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_xmult', vars = {card.ability.extra.x_mult}}})
            return {calculated = true}
        end
    end
}

local mondrian_sprite = {
    object_type = "Atlas",
    key = "mondrian",
    path = "j_cry_mondrian.png",
    px = 71,
    py = 95
}


local foodm = {
    object_type = "Joker",
    name = "cry-foodm",
    key = "foodm",
    config = {extra = {mult = 30, rounds_remaining = 2, text = "s"}, jolly = {t_mult = 8, type = 'Pair'}},
    pos = {x = 0, y = 0},
    loc_txt = {
        name = 'Fast Food M',
        text = {
            "{C:mult}+#1#{} Mult",
            "{C:red}self destructs{} after {C:attention}#2#{} round#3#,",
            "Increased by {C:attention}1{} round when",
            "{C:attention}Jolly Joker{} is {C:attention}sold{}",
            "{C:inactive,s:0.8}2 McDoubles, 2 McChickens{}",
            "{C:inactive,s:0.8}Large Fries, 20 Piece{}",
            "{C:inactive,s:0.8}& Large Cake{}"
        }
    },
    rarity = 1,
    cost = 5,
    discovered = true,
    atlas = "foodm",
    blueprint_compat = true,
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue+1] = { set = 'Joker', key = 'j_jolly', specific_vars = {self.config.jolly.t_mult, self.config.jolly.type} }
        return {vars = {center.ability.extra.mult, center.ability.extra.rounds_remaining, center.ability.extra.text}}
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and (card.ability.extra.mult > 0) and not context.before and not context.after then
            return {
                message = localize{type='variable',key='a_mult',vars={card.ability.extra.mult}},
                mult_mod = card.ability.extra.mult, 
                colour = G.C.MULT
            }
        end
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition and not context.retrigger_joker then
            card.ability.extra.rounds_remaining = card.ability.extra.rounds_remaining - 1
            if card.ability.extra.rounds_remaining > 0 then
                return {
                    message = {"-1 Round"},
                    colour = G.C.FILTER
                }
            else
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('tarot1')
                        card.T.r = -0.2
                        card:juice_up(0.3, 0.4)
                        card.states.drag.is = true
                        card.children.center.pinch.x = true
                        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                            func = function()
                                G.jokers:remove_card(card)
                                card:remove()
                                card = nil
                                return true;
                            end
                        }))
                        return true
                    end
                }))
                return {
                    message = "M!"
                }
            end
        end
        if context.selling_card and context.card.ability.name == "Jolly Joker" and not context.blueprint and not context.retrigger_joker then
            card.ability.extra.rounds_remaining = card.ability.extra.rounds_remaining + 1
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_rounds_remaining', vars = {card.ability.extra.rounds_remaining}}})
            return {calculated = true}
        end
        if card.ability.extra.rounds_remaining == 1 then
            card.ability.extra.text = ""
        end
    end
}
local foodm_sprite = {
    object_type = "Atlas",
    key = "foodm",
    path = "j_cry_fastfoodm.png",
    px = 71,
    py = 95
}
