--Tearlaments Lilia
local s,id=GetID()
function s.initial_effect(c)
	--This card's name becomes "Tearlaments Kitkallos" while on the field or in the GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetValue(92731385) -- Card ID of "Tearlaments Kitkallos"
	c:RegisterEffect(e1)
	local fusparams = {matfilter=Card.IsAbleToDeck,extrafil=s.extramat,extraop=s.extraop,gc=Fusion.ForcedHandler,extratg=s.extratarget}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e) return Duel.GetCurrentPhase()~=PHASE_DAMAGE and e:GetHandler():IsReason(REASON_EFFECT) end)
	e2:SetTarget(Fusion.SummonEffTG(fusparams))
	e2:SetOperation(Fusion.SummonEffOP(fusparams))
	c:RegisterEffect(e2)
end
s.listed_series={SET_TEARLAMENTS}
function s.extramat(e,tp,mg)
	return Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,nil)
end
function s.extratarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE)
end
function s.extraop(e,tc,tp,sg)
	local gg=sg:Filter(Card.IsLocation,nil,LOCATION_HAND|LOCATION_GRAVE)
	if #gg>0 then Duel.HintSelection(gg,true) end
	local rg=sg:Filter(Card.IsFacedown,nil)
	if #rg>0 then Duel.ConfirmCards(1-tp,rg) end
	Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	local dg=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_DECK)
	local ct=dg:FilterCount(Card.IsControler,nil,tp)
	if ct>0 then
		Duel.SortDeckbottom(tp,tp,ct)
	end
	if #dg>ct then
		Duel.SortDeckbottom(tp,1-tp,#dg-ct)
	end
	sg:Clear()
end