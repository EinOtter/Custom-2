--Invading the Hidden City
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)

	--GY destruction replacement
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end

--Filters
function s.setfilter(c)
	return (c:IsSetCard(SET_SUBTERROR) and c:IsType(TYPE_SPELL+TYPE_TRAP))
		or c:IsCode(05697558) --The Hidden City
		or c:IsCode(06589707) --Terrors in the Hidden City (change if custom ID differs)
		and c:IsSSetable()
end

function s.thfilter(c)
	return c:IsSetCard(SET_SUBTERROR) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

--Activation choice
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
			or Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	if not (b1 or b2) then return end

	local op=Duel.SelectOption(tp,
		aux.Stringid(id,0), --Set option
		aux.Stringid(id,1)) --Search monster

	if op==0 and b1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SSet(tp,g:GetFirst())
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end

--Destruction replacement in GY
function s.repfilter(c,tp)
	return c:IsFaceup() and (c:IsSetCard(0x90) or c:IsFacedown())
		and c:IsControler(tp) and c:IsOnField()
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return eg:IsExists(s.repfilter,1,nil,tp)
			and e:GetHandler():IsAbleToRemove()
	end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,2))
end

function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end