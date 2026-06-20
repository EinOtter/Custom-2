--Laufeyson of the Nordic Alfar
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon from hand
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    -- Send 1 "Nordic" card from Deck to GY on summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.tgtg)
    e2:SetOperation(s.tgop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)

    -- Negate while you control "Loki"
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_CHAINING)
    e4:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
    e4:SetCountLimit(1,{id,1})
    e4:SetCondition(s.negcon)
    e4:SetCost(s.negcost)
    e4:SetTarget(s.negtg)
    e4:SetOperation(s.negop)
    c:RegisterEffect(e4)

    -- Return to hand during End Phase
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_PHASE+PHASE_END)
    e5:SetRange(LOCATION_REMOVED)
    e5:SetCountLimit(1,{id,2})
    e5:SetCondition(s.retcon)
    e5:SetOperation(s.retop)
    c:RegisterEffect(e5)
end

-- Special Summon condition
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and 
        (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 
        or Duel.IsExistingMatchingCard(s.aesirfilter,tp,LOCATION_MZONE,0,1,nil))
end
function s.aesirfilter(c)
    return c:IsFaceup() and (c:IsSetCard(SET_NORDIC) or c:IsSetCard(SET_AESIR))
end

-- Send "Nordic" card to GY
function s.tgfilter(c)
    return c:IsSetCard(SET_NORDIC) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end

-- Negate effect while you control "Loki, Lord of the Aesir"
function s.lokifilter(c)
    return c:IsFaceup() and c:IsCode(67098114)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsChainNegatable(ev) and Duel.IsExistingMatchingCard(s.lokifilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToRemoveAsCost() end
    Duel.Remove(c,POS_FACEUP,REASON_COST)
    c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsDestructable() then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg,REASON_EFFECT)
    end
end

-- Return to hand at End Phase if negation was used
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetFlagEffect(id)>0
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.SendtoHand(c,tp,REASON_EFFECT)
end