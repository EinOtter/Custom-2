--Gigantic Spright Overlord
local s,id=GetID()
function s.initial_effect(c)
    --Xyz Summon
    Xyz.AddProcedure(c,nil,2,2)
    c:EnableReviveLimit()
--Can use Link 2 monsters as Level 2 materials
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetCode(EFFECT_XYZ_LEVEL)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e0:SetTarget(function(e,c) return c:IsLink(2) end)
	e0:SetValue(function(e,_,rc) return rc==e:GetHandler() and 2 or 0 end)
	c:RegisterEffect(e0)
    --Chain block if Link monster was used
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_MATERIAL_CHECK)
    e1:SetValue(s.valcheck)
    c:RegisterEffect(e1)

    --Banishing Quick Effect
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e2:SetCost(s.rmcost)
    e2:SetTarget(s.rmtg)
    e2:SetOperation(s.rmop)
    c:RegisterEffect(e2)

    --Floating effect
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)

    --Apply chain block immunity if Link monster used
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_CANNOT_ACTIVATE)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(1,0)
    e4:SetCondition(s.chaincon)
    e4:SetValue(s.chainlimit)
    c:RegisterEffect(e4)
end

function s.valcheck(e,c)
    local g=c:GetMaterial()
    local link=false
    for tc in aux.Next(g) do
        if tc:IsType(TYPE_LINK) then
            link=true
            break
        end
    end
    if link then
        c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
    end
end

function s.chaincon(e)
    return e:GetHandler():GetFlagEffect(id)>0
end
function s.chainlimit(e,re,tp)
    local rc=re:GetHandler()
    return rc:IsSetCard(SET_SPRIGHT) or rc:IsCode(id)
end

function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_ALL,LOCATION_ONFIELD+LOCATION_GRAVE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
    if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
        if Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE,0,1,nil,TYPE_MONSTER)
            and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil)
            and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
            local g2=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
            if #g2>0 then
                Duel.Remove(g2,POS_FACEUP,REASON_EFFECT)
            end
        end
    end
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return rp~=tp and e:GetHandler():IsReason(REASON_EFFECT+REASON_BATTLE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_SPRIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
    if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
        local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_GRAVE,0,nil)
        local tg=g:Filter(Card.IsSetCard,nil,SET_SPRIGHT):Filter(Card.IsType,nil,TYPE_SPELL+TYPE_TRAP):Filter(Card.IsAbleToHand,nil)
        if #tg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local th=tg:Select(tp,1,1,nil)
            Duel.SendtoHand(th,tp,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,th)
        end
    end
end