--D/D/D Calamity King Hades Apocalypse
local s,id=GetID()
function s.initial_effect(c)
    --Pendulum Attribute
    Pendulum.AddProcedure(c)

    -- Special Summon from Pendulum Zone
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Scale becomes 10 if another "D/D" is in Pendulum Zone
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CHANGE_LSCALE)
    e2:SetCondition(s.scalecon)
    e2:SetValue(10)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_CHANGE_RSCALE)
    c:RegisterEffect(e3)

    -- Destroy card on Special Summon by other "D/D" effect
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetCondition(s.descon)
    e4:SetTarget(s.destg)
    e4:SetOperation(s.desop)
    c:RegisterEffect(e4)

    -- Add 1 "D/D" Pendulum Monster if destroyed by effect
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,2))
    e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCode(EVENT_DESTROYED)
    e5:SetCondition(s.thcon)
    e5:SetTarget(s.thtg)
    e5:SetOperation(s.thop)
    c:RegisterEffect(e5)
end

-- e1: Special Summon from Pendulum Zone
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
    return #g==0 or g:FilterCount(function(c) return c:IsSetCard(0xaf) end,nil)==#g
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        -- Halve ATK/DEF
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(c:GetBaseAttack()/2)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
        e2:SetValue(c:GetBaseDefense()/2)
        c:RegisterEffect(e2)
    end
end

-- e2/e3: Scale becomes 10 if another "D/D" in PZone
function s.scalecon(e)
    local tp=e:GetHandlerPlayer()
    local g=Duel.GetMatchingGroup(function(c) return c:IsSetCard(SET_DD) and c:IsType(TYPE_PENDULUM) and c~=e:GetHandler() end,tp,LOCATION_PZONE,0,nil)
    return #g>0
end

-- e4: Destroy a card if Special Summoned by "D/D" effect (but not itself)
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return re and re:GetHandler():IsSetCard(SET_DD) and re:GetHandler()~=c
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end

-- e5: Add "D/D" Pendulum when destroyed by card effect
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return (r&REASON_EFFECT)~=0
end
function s.thfilter(c)
    return c:IsSetCard(SET_DD) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand() and not c:IsCode(id)
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