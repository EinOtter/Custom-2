--Crystal Beast Azure Panther
local s,id=GetID()
function s.initial_effect(c)
    --Place Continuous "Crystal" or "Rainbow Bridge" Spell/Trap on summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.placetg)
    e1:SetOperation(s.placeop)
    c:RegisterEffect(e1)
    local e1b=e1:Clone()
    e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e1b)

    --Crystal Beast GY redirect (official method)
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
    e4:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e4:SetCondition(s.repcon)
    e4:SetOperation(s.cbop)
    c:RegisterEffect(e4)

    --Search "Crystal" Spell/Trap
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.thcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

--Crystal Beast redirect condition
function s.repcon(e)
    local c=e:GetHandler()
    return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end

--Crystal Beast redirect operation
function s.cbop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local e1=Effect.CreateEffect(c)
    e1:SetCode(EFFECT_CHANGE_TYPE)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
    e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
    c:RegisterEffect(e1)
    Duel.RaiseEvent(c,EVENT_CUSTOM+CARD_CRYSTAL_TREE,e,0,tp,0,0)
end

--Filters
function s.placefilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP)
        and c:IsType(TYPE_CONTINUOUS)
        and (c:IsSetCard(SET_CRYSTAL) or c:IsSetCard(SET_RAINBOW_BRIDGE))
        and not c:IsForbidden()
end

function s.thfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP)
        and c:IsSetCard(SET_CRYSTAL)
        and c:IsAbleToHand()
end

--Place effect
function s.placetg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
            and Duel.IsExistingMatchingCard(s.placefilter,tp,LOCATION_DECK,0,1,nil)
    end
end

function s.placeop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local g=Duel.SelectMatchingCard(tp,s.placefilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_HAND,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end

--Search effect cost
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
