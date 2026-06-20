--The Phantom Knights of Hasty Chevalier
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon procedure: 5 Level 3 monsters
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsLevel,3),5)
	c:EnableReviveLimit()

	--Alternative Xyz using PK Link monster
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.xyzcon2)
	e0:SetOperation(s.xyzop2)
	c:RegisterEffect(e0)

	--Gain ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1b)

	--Detach 1: PK effects become Quick Effects (approximation)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.qecost)
	e2:SetOperation(s.qeop)
	c:RegisterEffect(e2)

	--On Special Summon: choose effect
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.chosetg)
	e3:SetOperation(s.choseop)
	c:RegisterEffect(e3)
end

--Alt Xyz condition using PK Link
function s.pklinkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSetCard(SET_THE_PHANTOM_KNIGHTS)
end

function s.xyzcon2(e,c,og,min,max)
	if c==nil then return true end
	return Duel.IsExistingMatchingCard(s.pklinkfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end

function s.xyzop2(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,s.pklinkfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	c:SetMaterial(Group.FromCards(tc))
	Duel.Overlay(c,Group.FromCards(tc))
end

--ATK/DEF gain
function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(Card.IsSetCard,c:GetControler(),LOCATION_GRAVE+LOCATION_REMOVED,0,nil,SET_THE_PHANTOM_KNIGHTS)
	return g:GetCount()*300
end

--Detach cost
function s.qecost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

--Approximate Quick Effect enabling
function s.qeop(e,tp,eg,ep,ev,re,r,rp)
	--EDOPro limitation: cannot truly convert all PK effects to Quick Effects.
end

--On Summon: choose 1 effect
function s.chosetg(e,tp,eg,ep,ev,re,r,rp,chk)
	return true
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_THE_PHANTOM_KNIGHTS) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.choseop(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
	local op=Duel.SelectEffect(tp,
		{b1, "Special Summon 1 \"Phantom Knights\" monster from your GY or banishment"},
		{true, "Your cards are protected from the first destruction this turn"}
	)
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif op==2 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetTargetRange(LOCATION_ONFIELD,0)
		e1:SetValue(s.indct)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

function s.indct(e,re,r,rp)
	return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end