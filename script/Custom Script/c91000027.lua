--Virtual World Sovereign - Qingdi
local s,id=GetID()
function s.initial_effect(c)
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_VIRTUAL_WORLD),1,1,Synchro.NonTuner(nil),1,1)
	c:EnableReviveLimit()
    -- Negate + Optional Banish (Quick Effect)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)

    -- Search on sent to GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    -- Protection if "Virtual World Gate" is present
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.protcon)
    e3:SetValue(aux.tgoval)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e4:SetValue(1)
    c:RegisterEffect(e4)
end

-- (1) Negate & Optional Banish
function s.gyfilter(c)
    return c:IsSetCard(SET_VIRTUAL_WORLD) and c:IsAbleToDeck()
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() end
    if chk==0 then
        return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
            and Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        tc:RegisterEffect(e2)

        if g:GetFirst():IsMonster() and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local rg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
            if #rg>0 then
                Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
            end
        end
    end
end

-- (2) Search
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_EFFECT+REASON_BATTLE)
end
function s.thfilter(c)
    return c:IsSetCard(SET_VIRTUAL_WORLD) and ((c:IsType(TYPE_MONSTER) and c:IsLevel(3)) or c:IsType(TYPE_SPELL+TYPE_TRAP)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
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

-- (3) Protection condition
function s.protcon(e)
    return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsSetCard(SET_VIRTUAL_WORLD_GATE) and c:GetType()&TYPE_FIELD+TYPE_CONTINUOUS>0 end,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end