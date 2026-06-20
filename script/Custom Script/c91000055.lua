--Rank-Up-Magic Puppet Chaos
local s,id=GetID()
function s.initial_effect(c)
	--Activate: Rank-Up Xyz Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	--GY: return banished Gimmick Puppets to GY, then draw
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end

--Filters
function s.xyzfilter(c,tp,e)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(s.rumfilter,tp,LOCATION_EXTRA,0,1,nil,e,c:GetRank(),tp)
end

function s.rumfilter(c,e,rank,tp)
	return c:IsSetCard(SET_GIMMICK_PUPPET) and c:IsType(TYPE_XYZ)
		and c:GetRank()==rank+1
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.xyzfilter(chkc,tp,e) end
	if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,tp,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,e)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.rumfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tc:GetRank(),tp)
	local sc=g:GetFirst()
	if not sc then return end

	local mg=tc:GetOverlayGroup()
	if #mg>0 then Duel.Overlay(sc,mg) end
	sc:SetMaterial(Group.FromCards(tc))
	Duel.Overlay(sc,Group.FromCards(tc))
	Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
	sc:CompleteProcedure()

	--Grant draw effect
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	sc:RegisterEffect(e1)
end

--Draw effect
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
end

--GY effect
function s.gyfilter(c)
	return c:IsSetCard(SET_GIMMICK_PUPPET) and c:IsMonster() and c:IsFaceup()
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_REMOVED,0,1,nil)
			and Duel.IsPlayerCanDraw(tp,1)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_REMOVED,0,1,3,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end