import { useBackend } from '../backend';
import { Box, Button, Flex, Grid, Section, Tabs } from '../components';
import { Window } from '../layouts';

interface Contract {
  id: string;
  name: string;
  reward: number;
  req: string;
  desc: string;
}

interface ShopItem {
  id: string;
  name: string;
  cost: number;
}

interface SmugglerData {
  credits: number;
  active_tab: 'light' | 'medium' | 'high';
  constant_contracts: Contract[];
  unique_contracts: Contract[];
  renewable_contracts: Contract[];
  shop_items: {
    light: ShopItem[];
    medium: ShopItem[];
    high: ShopItem[];
  };
}

export const Smuggler = (props, context) => {
  const { act, data } = useBackend<SmugglerData>(context);

  const {
    credits = 0,
    active_tab = 'light',
    constant_contracts = [],
    unique_contracts = [],
    renewable_contracts = [],
    shop_items = { light: [], medium: [], high: [] },
  } = data;

  return (
    <Window width={1050} height={680} title="Smuggler's Stash">
      <Window.Content>
        <Flex fill>
          {/* ЛЕВАЯ КОЛОНКА: Контракты */}
          <Flex.Item width="40%" display="flex" flexDirection="column" mr={2}>
            {/* Блок Баланса */}
            <Section mb={1}>
              <Flex align="center" justify="space-between">
                <Box fontSize="16px" bold color="label">
                  Баланс:{' '}
                  <Box inline color="good">
                    {credits} ₽
                  </Box>
                </Box>
                <Button icon="money-bill-wave" onClick={() => act('withdraw')}>
                  Вывести
                </Button>
              </Flex>
            </Section>

            {/* Скроллируемый список контрактов */}
            <Flex.Item grow scrollable mb={1}>
              {/* Постоянные */}
              <Section title="Постоянные контракты" mb={1}>
                {constant_contracts.map((contract) => (
                  <Box
                    key={contract.id}
                    p={1}
                    mb={0.5}
                    backgroundColor="rgba(200, 200, 200, 0.05)"
                    borderLeft="4px solid #5e4e38"
                    tooltip={contract.desc}>
                    <Flex justify="space-between" bold>
                      <Box color="label">{contract.name}</Box>
                      <Box color="good">+{contract.reward} ₽</Box>
                    </Flex>
                    <Box fontSize="11px" color="muted">
                      Требуется: {contract.req}
                    </Box>
                  </Box>
                ))}
              </Section>

              {/* Уникальные */}
              <Section title="Уникальные контракты (Max 3)" mb={1}>
                {unique_contracts.map((contract) => (
                  <Box
                    key={contract.id}
                    p={1}
                    mb={0.5}
                    backgroundColor="rgba(200, 200, 200, 0.05)"
                    borderLeft="4px solid #7030a0"
                    tooltip={contract.desc}>
                    <Flex justify="space-between" bold>
                      <Box color="label">{contract.name}</Box>
                      <Box color="purple">+{contract.reward} ₽</Box>
                    </Flex>
                    <Box fontSize="11px" color="muted">
                      Требуется: {contract.req}
                    </Box>
                  </Box>
                ))}
              </Section>

              {/* Восполняемые */}
              <Section title="Восполняемые контракты (Max 3)">
                {renewable_contracts.map((contract) => (
                  <Box
                    key={contract.id}
                    p={1}
                    mb={0.5}
                    backgroundColor="rgba(200, 200, 200, 0.05)"
                    borderLeft="4px solid #2e5a1c"
                    tooltip={contract.desc}>
                    <Flex justify="space-between" bold>
                      <Box color="label">{contract.name}</Box>
                      <Box color="good">+{contract.reward} ₽</Box>
                    </Flex>
                    <Box fontSize="11px" color="muted">
                      Требуется: {contract.req}
                    </Box>
                  </Box>
                ))}
              </Section>
            </Flex.Item>

            {/* Закрепленная кнопка сдачи */}
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

          {/* ПРАВАЯ КОЛОНКА: Магазин */}
          <Flex.Item width="60%" display="flex" flexDirection="column">
            <Section
              title="Доступное снаряжение"
              fill
              display="flex"
              flexDirection="column">
              {/* Табы категорий */}
              <Tabs mb={1}>
                <Tabs.Tab
                  selected={active_tab === 'light'}
                  onClick={() => act('select_tab', { tab: 'light' })}>
                  Лёгкое
                </Tabs.Tab>
                <Tabs.Tab
                  selected={active_tab === 'medium'}
                  onClick={() => act('select_tab', { tab: 'medium' })}>
                  Среднее
                </Tabs.Tab>
                <Tabs.Tab
                  selected={active_tab === 'high'}
                  onClick={() => act('select_tab', { tab: 'high' })}>
                  Тяжёлое
                </Tabs.Tab>
              </Tabs>

              {/* Сетка товаров */}
              <Flex.Item grow scrollable>
                <Grid columns={2} spacing={1}>
                  {(shop_items[active_tab] || []).map((item) => (
                    <Grid.Column key={item.id}>
                      <Box
                        p={1}
                        border="1px solid rgba(200, 200, 200, 0.1)"
                        height="100%"
                        display="flex"
                        flexDirection="column"
                        justifyContent="space-between">
                        <Box mb={1}>
                          <Flex justify="space-between" bold>
                            <Box color="label">{item.name}</Box>
                            <Box color="bad">{item.cost} ₽</Box>
                          </Flex>
                        </Box>
                        <Button
                          fluid
                          disabled={credits < item.cost}
                          onClick={() => act('buy', { id: item.id })}
                          icon="shopping-cart">
                          Купить
                        </Button>
                      </Box>
                    </Grid.Column>
                  ))}
                </Grid>
              </Flex.Item>
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
