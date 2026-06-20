--Virtual World Sage – Jiankang
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)

	-- (1) Send 1 VW of different type and draw 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)

	-- (2) Special Summon Level 3 or lower VW from GY (simple version)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,2})
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	-- (3) Add 1 VW card from GY or Banished to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,3})
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.rctg)
	e3:SetOperation(s.rcop)
	c:RegisterEffect(e3)
end

-- (1) Synchro Summon Condition
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.tgfilter(c,typelist)
	return c:IsSetCard(SET_VIRTUAL_WORLD) and c:IsAbleToGrave()
		and not typelist[c:GetType()&0x7]
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local typelist={[TYPE_MONSTER]=false,[TYPE_SPELL]=false,[TYPE_TRAP]=false}
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
	for tc in g:Iter() do
		typelist[tc:GetType()&0x7] = true
	end
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,typelist)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local typelist={[TYPE_MONSTER]=false,[TYPE_SPELL]=false,[TYPE_TRAP]=false}
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
	for tc in g:Iter() do
		typelist[tc:GetType()&0x7] = true
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,typelist)
	if #sg>0 and Duel.SendtoGrave(sg,REASON_EFFECT)>0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

-- (2) Simple GY trigger effect
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(function(c)
		return c:IsSetCard(SET_VIRTUAL_WORLD) and c:IsControler(tp)
	end,1,nil)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_VIRTUAL_WORLD) and c:IsLevelBelow(3)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- (3) Add from GY or Banished
function s.rcfilter(c)
	return c:IsSetCard(SET_VIRTUAL_WORLD) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rcfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.rcop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.rcfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end