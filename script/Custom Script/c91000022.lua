--Sky Striker Ace - Lilie
local s,id=GetID()
function s.initial_effect(c)
    -- Quick Summon + Negate + Recycle from GY
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_NEGATE+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.negcon)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)

    -- GY Effect: Return + Add to hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.retcon)
    e2:SetTarget(s.rettg)
    e2:SetOperation(s.retop)
    c:RegisterEffect(e2)
end

-- e1 conditions
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER)
        and Duel.IsChainNegatable(ev)
end
function s.thfilter(c)
    return c:IsSetCard(SET_SKY_STRIKER) and c:IsAbleToHand()
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
            and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.NegateActivation(ev) and c:IsRelateToEffect(e) then
        if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
            if #g>0 then
                Duel.SendtoHand(g,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,g)
            end
        end
    end
end

-- e2 conditions
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    return re:IsActiveType(TYPE_SPELL)
end
function s.retfilter(c)
    return c:IsSetCard(SET_SKY_STRIKER) and c:IsAbleToHand() and c:IsOnField()
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingTarget(s.retfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectTarget(tp,s.retfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
        if c:IsRelateToEffect(e) then
            Duel.SendtoHand(c,nil,REASON_EFFECT)
        end
    end
end