import { useBackend } from '../backend';
import { Box, Button, Flex, Icon, Section, Tabs } from '../components';
import { Window } from '../layouts';

interface Contract {
  id?: string;
  name: string;
  reward: number;
  req: string;
  desc: string;
}

interface ShopItem {
  id: string;
  name: string;
  cost: number;
  goal_type?: string;
  locked?: boolean | number;
}

interface Goal {
  goal_type: string;
  name: string;
  done: boolean;
  desc: string;
  reward: number | null;
}

type ShopTier = 'light' | 'medium' | 'high';

interface SmugglerData {
  credits: number;
  active_tab: ShopTier;
  left_tab: 'goals' | 'orders';
  reroll_cooldown: number;
  constant_contracts: Contract[];
  unique_contracts: Contract[];
  renewable_contracts: Contract[];
  unlocked_tiers?: Partial<Record<ShopTier, boolean | number>>;
  tier_unlock_costs?: Partial<Record<ShopTier, number>>;
  shop_items: {
    light: ShopItem[];
    medium: ShopItem[];
    high: ShopItem[];
    goals?: Goal[] | Goal[][];
  };
}

const DEFAULT_UNLOCKED_TIERS: Record<ShopTier, boolean> = {
  light: true,
  medium: false,
  high: false,
};

const CATEGORIES = {
  constant: {
    title: 'Постоянные',
    color: 'label',
    reward: 'good',
    border: '1px solid rgba(200, 200, 200, 0.35)',
    bg: 'rgba(200, 200, 200, 0.06)',
    rerollable: false,
  },
  unique: {
    title: 'Уникальные (Max 3)',
    color: 'purple',
    reward: 'purple',
    border: '1px solid rgba(180, 70, 220, 0.55)',
    bg: 'rgba(180, 70, 220, 0.08)',
    rerollable: true,
  },
  renewable: {
    title: 'Восполняемые (Max 3)',
    color: 'good',
    reward: 'good',
    border: '1px solid rgba(90, 190, 90, 0.55)',
    bg: 'rgba(90, 190, 90, 0.08)',
    rerollable: true,
  },
} as const;

type CategoryKey = keyof typeof CATEGORIES;

export const Smuggler = (props, context) => {
  const { act, data } = useBackend<SmugglerData>(context);

  const {
    credits = 0,
    active_tab = 'light',
    left_tab = 'goals',
    reroll_cooldown = 0,
    constant_contracts = [],
    unique_contracts = [],
    renewable_contracts = [],
    unlocked_tiers,
    tier_unlock_costs = {},
    shop_items = { light: [], medium: [], high: [] },
  } = data;

  // Сливаем дефолты с тем, что приехало с бэкенда,
  // чтобы при любом косяке сериализации light не оказался залочен
  const unlockedMap: Record<ShopTier, boolean> = {
    ...DEFAULT_UNLOCKED_TIERS,
    ...(unlocked_tiers as any),
  };

  // Уровень можно залочить ТОЛЬКО если у него есть цена разблокировки.
  // У light цены нет => он никогда не заблокирован.
  const tierCost = tier_unlock_costs[active_tab];
  const tierLocked = tierCost !== undefined && !unlockedMap[active_tab];

  // Цели могут приехать как [], как {} (пустой список из DM) или с обёрткой
  const rawGoals: any = (shop_items as any).goals;
  const goals: Goal[] = (Array.isArray(rawGoals) ? rawGoals : [])
    .reduce((acc: any[], g: any) => acc.concat(Array.isArray(g) ? g : [g]), [])
    .filter((g: any) => g && typeof g === 'object');

  const goalNameByType: Record<string, string> = {};
  for (const g of goals) {
    goalNameByType[g.goal_type] = g.name;
  }

  /* Карточка контракта */
  const renderContractCard = (
    c: Contract,
    idx: number,
    catKey: CategoryKey
  ) => {
    const cat = CATEGORIES[catKey];
    return (
      <Box
        key={`${c.name}_${idx}`}
        p={1}
        mb={0.5}
        tooltip={c.desc}
        style={{
          border: '1px solid rgba(200, 200, 200, 0.2)',
          backgroundColor: 'rgba(0, 0, 0, 0.35)',
        }}>
        <Flex align="center" justify="space-between">
          <Flex.Item grow={1} mr={1}>
            <Box bold color="label">
              {c.name}
            </Box>
            <Box fontSize="11px" color="muted">
              Требуется: {c.req}
            </Box>
          </Flex.Item>
          <Box bold color={cat.reward} textAlign="right">
            +{c.reward} ₽
          </Box>
          {cat.rerollable ? (
            <Flex.Item shrink={0} ml={1}>
              <Button
                icon="dice"
                disabled={reroll_cooldown > 0}
                tooltip={
                  reroll_cooldown > 0
                    ? `Замена доступна через ${reroll_cooldown} сек.`
                    : 'Заменить контракт (общий кулдаун 2 минуты)'
                }
                onClick={() => act('reroll', { id: c.id })}
              />
            </Flex.Item>
          ) : null}
        </Flex>
      </Box>
    );
  };

  const renderCategory = (catKey: CategoryKey, contracts: Contract[]) => {
    const cat = CATEGORIES[catKey];
    return (
      <Box
        key={catKey}
        p={1}
        mb={1}
        style={{ border: cat.border, backgroundColor: cat.bg }}>
        <Box bold color={cat.color} mb={1}>
          {cat.title}
        </Box>
        {contracts.length === 0 ? (
          <Box color="muted">Нет контрактов.</Box>
        ) : (
          contracts.map((c, i) => renderContractCard(c, i, catKey))
        )}
      </Box>
    );
  };

  /* Карточка цели */
  const renderGoalCard = (g: Goal) => (
    <Box
      key={g.goal_type}
      p={1}
      mb={1}
      style={{
        border: g.done
          ? '1px solid rgba(90, 190, 90, 0.5)'
          : '1px solid rgba(200, 200, 200, 0.25)',
        backgroundColor: 'rgba(0, 0, 0, 0.3)',
      }}>
      <Flex align="center" justify="space-between">
        <Box bold color={g.done ? 'muted' : 'label'} mr={1}>
          {g.name}
        </Box>
        {g.reward !== null ? (
          <Box bold color="good" textAlign="right">
            +{g.reward} ₽
          </Box>
        ) : null}
      </Flex>
      {g.desc ? (
        <Box color="muted" fontSize="11px" mt={0.5}>
          {g.desc}
        </Box>
      ) : null}
      <Box mt={1} textAlign="right">
        <Button
          color={g.done ? 'good' : 'default'}
          disabled={!!g.done}
          icon={g.done ? 'check' : 'upload'}
          tooltip={
            g.done
              ? 'Цель уже выполнена'
              : 'Сдать предметы со схрона для этой цели'
          }
          onClick={() => act('fulfill_goal', { chosen_goal: g.goal_type })}>
          {g.done ? 'Выполнено' : 'Сдать'}
        </Button>
      </Box>
    </Box>
  );

  /* Вкладка магазина: замок только если у уровня есть цена и он не открыт */
  const renderShopTab = (tier: ShopTier, title: string) => {
    const cost = tier_unlock_costs[tier];
    const showLock = cost !== undefined && !unlockedMap[tier];
    return (
      <Tabs.Tab
        selected={active_tab === tier}
        onClick={() => act('select_tab', { tab: tier })}>
        {title}
        {showLock ? <Icon name="lock" color="bad" ml={1} /> : null}
      </Tabs.Tab>
    );
  };

  return (
    <Window width={1050} height={680} title="Smuggler's Stash">
      <Window.Content>
        <Flex fill>
          {/* ЛЕВАЯ КОЛОНКА */}
          <Flex.Item width="40%" display="flex" flexDirection="column" mr={2}>
            <Section mb={1}>
              <Flex align="center" justify="space-between">
                <Box fontSize="16px" bold color="label">
                  Баланс:{' '}
                  <Box inline color="good">
                    {credits} ₽
                  </Box>
                </Box>
                <Box>
                  <Button
                    icon="money-bill"
                    tooltip="Собрать наличные, лежащие на схроне, на счёт"
                    onClick={() => act('deposit')}>
                    Ввести
                  </Button>
                  <Button
                    icon="money-bill-wave"
                    tooltip="Выдать наличные со счёта"
                    onClick={() => act('withdraw')}>
                    Вывести
                  </Button>
                </Box>
              </Flex>
            </Section>

            {/* Переключение Цели/Контракты */}
            <Tabs mb={1}>
              <Tabs.Tab
                selected={left_tab === 'goals'}
                onClick={() => act('select_left_tab', { tab: 'goals' })}>
                Цели
              </Tabs.Tab>
              <Tabs.Tab
                selected={left_tab === 'orders'}
                onClick={() => act('select_left_tab', { tab: 'orders' })}>
                Контракты
              </Tabs.Tab>
            </Tabs>

            <Flex.Item grow scrollable mb={1}>
              {left_tab === 'goals' ? (
                <Section title="Цели">
                  {goals.length === 0 ? (
                    <Box color="muted">Нет активных целей.</Box>
                  ) : (
                    goals.map((g) => renderGoalCard(g))
                  )}
                </Section>
              ) : (
                <Section title="Контракты">
                  {renderCategory('constant', constant_contracts)}
                  {renderCategory('unique', unique_contracts)}
                  {renderCategory('renewable', renewable_contracts)}
                </Section>
              )}
            </Flex.Item>

            <Button
              fluid
              color="teal"
              lineHeight="2"
              textAlign="center"
              icon="upload"
              onClick={() => act('fulfill')}>
              СДАТЬ КОНТРАБАНДУ
            </Button>
          </Flex.Item>

          {/* ПРАВАЯ КОЛОНКА: магазин */}
          <Flex.Item width="60%" display="flex" flexDirection="column">
            <Section
              title="Доступное снаряжение"
              fill
              display="flex"
              flexDirection="column">
              <Tabs mb={1}>
                {renderShopTab('light', 'Лёгкое')}
                {renderShopTab('medium', 'Среднее')}
                {renderShopTab('high', 'Тяжёлое')}
              </Tabs>

              <Flex.Item grow scrollable>
                {/* Баннер разблокировки уровня */}
                {tierLocked ? (
                  <Box
                    p={1}
                    mb={1}
                    style={{
                      border: '1px solid rgba(190, 40, 40, 0.6)',
                      backgroundColor: 'rgba(190, 40, 40, 0.1)',
                    }}>
                    <Flex align="center" justify="space-between">
                      <Box bold color="bad">
                        <Icon name="lock" mr={1} />
                        Уровень заблокирован
                      </Box>
                      <Button
                        icon="unlock"
                        disabled={credits < (tierCost ?? 0)}
                        tooltip={
                          credits < (tierCost ?? 0)
                            ? `Недостаточно кредитов (нужно ${tierCost} ₽)`
                            : undefined
                        }
                        onClick={() =>
                          act('unlock_tier', { tier: active_tab })
                        }>
                        Разблокировать за {tierCost} ₽
                      </Button>
                    </Flex>
                  </Box>
                ) : null}

                <Flex wrap="wrap">
                  {(shop_items[active_tab] || []).map((item) => (
                    <Flex.Item key={item.id} width="33.33%" p={0.5}>
                      <Box
                        p={1}
                        height="100%"
                        style={{
                          border: item.locked
                            ? '1px solid rgba(190, 40, 40, 0.6)'
                            : '1px solid rgba(200, 200, 200, 0.3)',
                          backgroundColor: 'rgba(0, 0, 0, 0.3)',
                          minHeight: '70px',
                        }}>
                        <Flex
                          align="center"
                          justify="space-between"
                          height="100%">
                          <Flex.Item grow={1} mr={1}>
                            <Box bold color="label">
                              {item.locked ? (
                                <Icon
                                  name="lock"
                                  color="bad"
                                  mr={1}
                                  tooltip={`Сначала выполните цель: ${
                                    goalNameByType[item.goal_type || ''] ||
                                    item.goal_type
                                  }`}
                                />
                              ) : null}
                              {item.name}
                            </Box>
                            <Box bold color="bad">
                              {item.cost} ₽
                            </Box>
                            {item.locked ? (
                              <Box fontSize="10px" color="muted">
                                Цель:{' '}
                                {goalNameByType[item.goal_type || ''] ||
                                  item.goal_type}
                              </Box>
                            ) : null}
                          </Flex.Item>
                          <Flex.Item shrink={0}>
                            <Button
                              icon="shopping-cart"
                              disabled={
                                credits < item.cost ||
                                !!item.locked ||
                                tierLocked
                              }
                              tooltip={
                                tierLocked
                                  ? `Уровень заблокирован — разблокируйте за ${tierCost} ₽`
                                  : item.locked
                                    ? `Сначала выполните цель: ${
                                        goalNameByType[item.goal_type || ''] ||
                                        item.goal_type
                                      }`
                                    : credits < item.cost
                                      ? 'Недостаточно кредитов'
                                      : undefined
                              }
                              onClick={() => act('buy', { id: item.id })}>
                              Купить
                            </Button>
                          </Flex.Item>
                        </Flex>
                      </Box>
                    </Flex.Item>
                  ))}
                </Flex>
              </Flex.Item>
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
