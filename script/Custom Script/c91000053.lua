--Fire King High Avatar Yaksha
local s,id=GetID()
function s.initial_effect(c)
	--Hand: destroy 1 FIRE to Special Summon Fire King
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)

	--If destroyed and sent to GY: add Fire King S/T
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.thcon2)
	e2:SetTarget(s.thtg2)
	e2:SetOperation(s.thop2)
	c:RegisterEffect(e2)
end

--Main Phase only
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end

--Destroy 1 other FIRE monster
function s.desfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsMonster() and c:IsDestructable()
end

--Fire King to Special Summon (hand/GY)
function s.spfilter_hg(c,e,tp,dc)
	return c:IsSetCard(SET_FIRE_KING) and c:IsMonster()
		and not c:IsCode(id) and not c:IsCode(dc)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

--Fire King from Deck if condition met
function s.spfilter_deck(c,e,tp)
	return c:IsSetCard(SET_FIRE_KING) and c:IsMonster()
		and not c:IsCode(id)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,c)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and (
				Duel.IsExistingMatchingCard(s.spfilter_hg,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,c:GetCode())
				or Duel.IsExistingMatchingCard(s.spfilter_deck,tp,LOCATION_DECK,0,1,nil,e,tp)
			)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK)
end

function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,e:GetHandler())
	if #dg==0 then return end
	local dc=dg:GetFirst():GetCode()
	if Duel.Destroy(dg,REASON_EFFECT)==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=nil
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_FIRE_KING),tp,LOCATION_GRAVE,0,1,nil)
		or Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_FIRE_KING),tp,LOCATION_MZONE,0,1,nil) then
		--Check if Fire King was destroyed this turn
	end

	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_FIRE_KING),tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.spfilter_deck,tp,LOCATION_DECK,0,1,nil,e,tp)
		and Duel.GetFlagEffect(tp,id)~=0 then
		g=Duel.SelectMatchingCard(tp,s.spfilter_deck,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	else
		g=Duel.SelectMatchingCard(tp,s.spfilter_hg,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,dc)
	end

	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--Check if this card was destroyed
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end

--Fire King Spell/Trap in GY
function s.thfilter2(c)
	return c:IsSetCard(SET_FIRE_KING) and c:IsSpellTrap() and c:IsAbleToHand()
end

function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end