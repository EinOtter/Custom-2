--Virtual World Gate – Huichao
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-- (1) Shuffle 1 face-up card on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tdcon)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)

	-- (2) Recycle from GY or banished
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.rctg)
	e2:SetOperation(s.rcop)
	c:RegisterEffect(e2)
end

-- (1) Shuffle opponent’s card
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_VIRTUAL_WORLD),tp,LOCATION_MZONE,0,1,nil)
end
function s.tdfilter(c)
	return c:IsFaceup() and c:IsAbleToDeck()
end
function s.tdcfilter(c)
	return c:IsSetCard(SET_VIRTUAL_WORLD) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tdcfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=Duel.SelectMatchingCard(tp,s.tdcfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	if #g1==0 or Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g2=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g2>0 then
		Duel.SendtoDeck(g2,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

-- (2) Recycle 1-2 VW cards from GY or banished
function s.rcfilter(c)
	return c:IsSetCard(SET_VIRTUAL_WORLD) and not c:IsCode(id) and c:IsAbleToDeck()
end
function s.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rcfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.rcop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.rcfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,2,nil)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end