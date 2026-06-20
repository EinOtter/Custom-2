--CXyz Gimmick Puppet Corrupted Heir
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_MACHINE),9,3)

	--Detach 1: banish from opponent GY, burn, then choose effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)

	--Replacement effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_SEND_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end

--Cost: detach 1
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.rmfilter(c)
	return c:IsAbleToRemove() and c:IsLocation(LOCATION_GRAVE)
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_GRAVE,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_GRAVE)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,0,LOCATION_GRAVE,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end

	if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		if tc:IsType(TYPE_MONSTER) and tc:GetAttack()>0 then
			Duel.Damage(1-tp,tc:GetAttack(),REASON_EFFECT)
		end

		if not tc:IsLocation(LOCATION_REMOVED) then return end
		if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			--Attach as material
			Duel.Overlay(e:GetHandler(),Group.FromCards(tc))
		else
			--Negate its effects while banished
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			tc:RegisterEffect(e2)
		end
	end
end

--Replacement filter: check if this has Gimmick Puppet Xyz material
function s.matfilter(c)
	return c:IsSetCard(SET_GIMMICK_PUPPET) and c:IsType(TYPE_XYZ)
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:GetHandler():GetOverlayGroup():IsExists(s.matfilter,1,nil)
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,nil)
	end
	return Duel.SelectYesNo(tp,aux.Stringid(id,2))
end

function s.repval(e,c)
	return c:IsControler(e:GetHandlerPlayer())
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DETACHFROM)
	local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsSetCard,SET_GIMMICK_PUPPET),tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		tc:RemoveOverlayCard(tp,2,2,REASON_EFFECT)
	end
end