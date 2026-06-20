--Snake-Eyes Blackguard
local s,id=GetID()
function s.initial_effect(c)
    -- Search + send 1 Level 1 FIRE from Deck
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)

    -- GY effect: recycle & Special Summon
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCost(aux.bfgcost)
    e3:SetTarget(s.gytg)
    e3:SetOperation(s.gyop)
    c:RegisterEffect(e3)

	-- Quick Effect: Send 2 cards (including this) to summon from Deck/hand
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,{id,2})
    e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
    e4:SetCondition(s.qecon)
    e4:SetTarget(s.qetg)
    e4:SetOperation(s.qeop)
    c:RegisterEffect(e4)
end

-- e1/e2: Search + Send
function s.thfilter(c)
    return c:IsSetCard(SET_SNAKE_EYE) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.tgfilter(c)
    return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLevel(1) and c:IsAbleToGrave()
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
        if Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local tg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
            Duel.SendtoGrave(tg,REASON_EFFECT)
        end
    end
end

-- e3: GY effect
function s.tdfilter(c)
    return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToDeck()
end
function s.spfilter(c,e,tp)
    return c:IsRace(RACE_PYRO) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLevel(1)
        and (c:IsCanBeSpecialSummoned(e,0,tp,false,false) or c:IsLocation(LOCATION_HAND))
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local tdg=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
    if #tdg>0 and Duel.SendtoDeck(tdg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local spg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
        if #spg>0 then
            local tc=spg:GetFirst()
            if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
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
end
-- e4: Quick effect - send 2 to GY (including this) to SS 1 Snake-Eyes
function s.qecon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase()
end
function s.qefilter(c,e,tp)
    return c:IsSetCard(SET_SNAKE_EYE) and not c:IsCode(id)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.qetg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return c:IsAbleToGrave()
            and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,c)
            and Duel.IsExistingMatchingCard(s.qefilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
function s.qeop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsAbleToGrave() then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,function(tc) return tc:IsFaceup() and tc:IsAbleToGrave() end,
        tp,LOCATION_ONFIELD,0,1,1,c)
    if #g>0 then
        g:AddCard(c)
        if Duel.SendtoGrave(g,REASON_EFFECT)==2 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local sg=Duel.SelectMatchingCard(tp,s.qefilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
            if #sg>0 then
                Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
            end
        end
    end
end