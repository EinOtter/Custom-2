--Sky Striker Maneuver - Assault Salvo
local s,id=GetID()
function s.initial_effect(c)
    -- Activation
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id) -- once per turn
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Condition: No monsters in Main Monster Zones
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
        or not Duel.IsExistingMatchingCard(aux.NOT(Card.IsLocation),tp,LOCATION_MZONE,0,1,nil,LOCATION_MZONE)
end

-- Target: Destroy 1 or 2 opponent's monsters
function s.filter(c)
    return c:IsMonster() and c:IsDestructable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local ct=1
    if Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3 then ct=2 end
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,ct,nil) end
    local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,ct,ct,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

-- Operation: Destroy and negate effects
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e)
    if #g>0 then
        local destroyed=Duel.Destroy(g,REASON_EFFECT)
        for tc in aux.Next(g) do
            if tc:IsLocation(LOCATION_GRAVE+LOCATION_MZONE) and tc:IsFaceup() then
                -- Negate effects until end of turn
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_DISABLE)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                tc:RegisterEffect(e1)
                local e2=e1:Clone()
                e2:SetCode(EFFECT_DISABLE_EFFECT)
                tc:RegisterEffect(e2)
            end
        end
    end
end