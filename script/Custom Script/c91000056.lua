--CXyz Gimmick Puppet Gilded Bells 
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_MACHINE),9,3)

	--Detach 1: negate face-up card, burn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.negtg1)
	e1:SetOperation(s.negop1)
	c:RegisterEffect(e1)

	--Standby Phase: attach Gimmick Puppet from GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(s.attachtg)
	e2:SetOperation(s.attachop)
	c:RegisterEffect(e2)

	--If Rank-Up Summoned: omni-negate detach 3
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.rumcon)
	e3:SetCost(s.cost3)
	e3:SetTarget(s.negtg3)
	e3:SetOperation(s.negop3)
	c:RegisterEffect(e3)
end

--Cost: detach 1
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.faceupfilter(c)
	return c:IsFaceup() and c:IsNegatable()
end

function s.negtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and s.faceupfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.faceupfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.faceupfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,0,0)
end

function s.negop1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_MONSTER) then
			Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
		end
	end
end

--Attach from GY
function s.attachfilter(c)
	return c:IsSetCard(SET_GIMMICK_PUPPET) and c:IsMonster()
end

function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.attachfilter,tp,LOCATION_GRAVE,0,1,nil)
			and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_GIMMICK_PUPPET),tp,LOCATION_MZONE,0,1,nil)
	end
end

function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,s.attachfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsSetCard,SET_GIMMICK_PUPPET),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		Duel.Overlay(tc,g)
	end
end

--Rank-Up condition (fixed)
function s.rumcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_XYZ) and c:GetMaterialCount()>0
end

--Cost: detach 3
function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,3,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,3,3,REASON_COST)
end

function s.negtg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsChainNegatable(ev) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end

function s.negop3(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
end