--Virtual World Beacon - Qinglian
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-- Special Summon + Send
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- Destruction Replacement
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)

	-- GY Search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id, 1})
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

-- Check control of only VW monsters or none
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return #g==0 or g:FilterCount(function(c) return c:IsSetCard(SET_VIRTUAL_WORLD) end,nil)==#g
end

function s.revealfilter(c,tp)
	return c:IsSetCard(SET_VIRTUAL_WORLD) and Duel.IsExistingMatchingCard(s.sendfilter,tp,LOCATION_DECK,0,1,nil,c)
end
function s.sendfilter(c,rc)
	return c:IsSetCard(SET_VIRTUAL_WORLD)
		and c:IsAbleToGrave()
		and c:GetType()&0x7~=rc:GetType()&0x7
		and not c:IsCode(rc:GetCode())
end
function s.spfilter(c,e,tp,rc)
	return c:IsSetCard(SET_VIRTUAL_WORLD)
		and c:IsMonster()
		and not c:IsCode(rc:GetCode())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.revealfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp)
	end
	return true
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rg=Duel.SelectMatchingCard(tp,s.revealfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp)
	if #rg==0 then return end
	local rc=rg:GetFirst()
	Duel.ConfirmCards(1-tp,rc)
	Duel.ShuffleHand(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=Duel.SelectMatchingCard(tp,s.sendfilter,tp,LOCATION_DECK,0,1,1,nil,rc)
	if #tg>0 and Duel.SendtoGrave(tg,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local spg=Duel.SelectMatchingCard(tp,function(c) return s.spfilter(c,e,tp,rc) end,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
		if #spg>0 then
			Duel.SpecialSummon(spg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

-- Destruction replacement
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_VIRTUAL_WORLD) and c:IsControler(tp)
		and c:IsOnField() and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end
function s.repcheck(c)
	return c:IsSetCard(SET_VIRTUAL_WORLD) and c:IsAbleToRemove()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return eg:IsExists(s.repfilter,1,nil,tp)
			and Duel.IsExistingMatchingCard(s.repcheck,tp,LOCATION_GRAVE,0,1,nil)
	end
	return Duel.SelectYesNo(tp,aux.Stringid(id,2))
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.repcheck,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

-- Search Virtual World Gate Spell/Trap
function s.thfilter(c)
	return c:IsSetCard(SET_VIRTUAL_WORLD) and c:IsSpellTrap() and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end