--Psy-Frame Quantum-Driver
local s,id=GetID()
function s.initial_effect(c)
    -- Name becomes "Psy-Frame Driver"
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetRange(LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_DECK)
    e1:SetValue(49036338) -- ID of "Psy-Frame Driver"
    c:RegisterEffect(e1)
--synchro effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.sccon)
	e2:SetTarget(s.sctarg)
	e2:SetOperation(s.scop)
	e2:SetCountLimit(1)
	c:RegisterEffect(e2)
-- Be treated as Level 7 for Synchro Summon
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SYNCHRO_LEVEL)
    e1:SetValue(s.synlevel)
    c:RegisterEffect(e1)
end

function s.synlevel(e,c)
    local lv=e:GetHandler():GetLevel()
    return 7*65536 + lv  -- Treated as 7 when used for Synchro
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp) and (Duel.IsMainPhase())
end
function s.sctarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(id)==0
		and Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end
    