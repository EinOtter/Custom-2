--Custom Aesir Synchro
local s,id=GetID()
function s.initial_effect(c)
    -- Synchro summon procedure
    Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,SET_NORDIC_ASCENDANT),1,1,nil,1,99)
    c:EnableReviveLimit()

    -- Quick negate during Main Phase (unrespondable)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.negcon)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)

    -- Cannot respond to this effect
    local e1x=Effect.CreateEffect(c)
    e1x:SetType(EFFECT_TYPE_FIELD)
    e1x:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1x:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1x:SetRange(LOCATION_MZONE)
    e1x:SetTargetRange(1,1)
    e1x:SetValue(s.aclimit)
    e1x:SetLabelObject(e1)
    c:RegisterEffect(e1x)

    -- Flag when sent to GY face-up
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCondition(function(e) return e:GetHandler():IsFaceup() end)
    e2:SetOperation(function(e) e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1) end)
    c:RegisterEffect(e2)

    -- Self revive during End Phase
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.spcon)
    e3:SetCost(s.spcost)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

-- (1) Quick negate during Main Phase
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase() and Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    Duel.NegateActivation(ev)
end
function s.aclimit(e,re,tp)
    local te=e:GetLabelObject()
    return Duel.GetCurrentChain()>0 and Duel.GetChainInfo(Duel.GetCurrentChain(),CHAININFO_TRIGGERING_EFFECT)==te
end

-- (2) Self revive during End Phase
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetFlagEffect(id)>0
end
function s.costfilter(c)
    return c:IsSetCard(SET_NORDIC_ASCENDANT) and c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        -- Send 1 card from Deck to GY
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoGrave(g,REASON_EFFECT)
        end
    end
end