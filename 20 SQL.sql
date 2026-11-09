DROP TABLE IF EXISTS public.vendas CASCADE;
DROP TABLE IF EXISTS public.encomendas CASCADE;
DROP TABLE IF EXISTS public.produtos CASCADE;
DROP TABLE IF EXISTS public.clientes CASCADE;

-- 1. Tabela Clientes
CREATE TABLE public.clientes (
    id_clientes SERIAL,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150),
    telemovel VARCHAR(20),
    morada VARCHAR(250),
    CONSTRAINT pk_clientes PRIMARY KEY (id_clientes)
);

-- 2. Tabela Produtos
CREATE TABLE public.produtos (
    id_produto SERIAL,
    nome_produto VARCHAR(100) NOT NULL,
    preco NUMERIC(10, 2) NOT NULL,
    stock INT NOT NULL,
    acessorios VARCHAR(250),
    CONSTRAINT pk_produtos PRIMARY KEY (id_produto)
);

-- 3. Tabela Encomendas
CREATE TABLE public.encomendas (
    id_encomenda SERIAL,
    id_clientes INT,
    id_produto INT,
    data_encomenda DATE DEFAULT CURRENT_DATE,
    quantidade INT NOT NULL,
    CONSTRAINT pk_encomendas PRIMARY KEY (id_encomenda),
    CONSTRAINT fk_encomendas_clientes FOREIGN KEY (id_clientes) 
        REFERENCES public.clientes(id_clientes) ON DELETE CASCADE,
    CONSTRAINT fk_encomendas_produtos FOREIGN KEY (id_produto) 
        REFERENCES public.produtos(id_produto) ON DELETE CASCADE
);

-- 4. Tabela Vendas
CREATE TABLE public.vendas (
    id_venda SERIAL,
    id_encomenda INT,
    CONSTRAINT pk_vendas PRIMARY KEY (id_venda),
    CONSTRAINT fk_vendas_encomendas FOREIGN KEY (id_encomenda) 
        REFERENCES public.encomendas(id_encomenda) ON DELETE CASCADE
);

-- Inserção de 10 clientes mulheres
INSERT INTO public.clientes (nome, email, telemovel, morada) 
VALUES 
('Ana Silva', 'ana.silva@email.com', '912345678', 'Rua Augusta, Lisboa'),
('Maria Santos', 'maria.santos@email.com', '923456789', 'Avenida da Boavista, Porto'),
('Joana Rodrigues', 'joana.r@email.com', '934567890', 'Rua de Santa Catarina, Porto'),
('Beatriz Costa', 'beatriz.costa@email.com', '965432109', 'Praça do Giraldo, Évora'),
('Catarina Martins', 'catarina.m@email.com', '915987654', 'Rua Direita, Coimbra'),
('Sofia Oliveira', 'sofia.oliveira@email.com', '928765432', 'Avenida Central, Braga'),
('Inês Pereira', 'ines.pereira@email.com', '931234567', 'Rua do Alportel, Faro'),
('Filipa Almeida', 'filipa.a@email.com', '961112233', 'Largo da Oliveira, Guimarães'),
('Margarida Ribeiro', 'margarida.r@email.com', '919998877', 'Rua das Flores, Aveiro'),
('Diana Fernandes', 'diana.f@email.com', '927776655', 'Avenida Luísa Todi, Setúbal');

-- Inserção dos produtos e acessórios Sliq
INSERT INTO public.produtos (nome_produto, preco, stock, acessorios) 
VALUES 
('Modelador Sliq Base', 149.99, 50, 'Corpo Principal + Cabo'),
('Bocal Secador Concentrador', 25.00, 100, 'Bocal de secagem rápida'),
('Escova Alisadora Retangular', 35.00, 80, 'Cerdas firmes anti-frizz'),
('Escova de Volume Oval', 35.00, 75, 'Efeito volumizador'),
('Modelador de Caracóis Coanda', 45.00, 60, 'Tubo modelador 30mm');

-- Inserção das Encomendas realizadas pelas clientes
INSERT INTO public.encomendas (id_clientes, id_produto, quantidade) 
VALUES 
(1, 1, 1),
(2, 3, 1),
(3, 1, 1),
(4, 2, 2),
(5, 1, 1),
(6, 5, 1),
(7, 4, 1),
(8, 1, 1),
(9, 3, 1),
(10, 1, 1);

-- Inserção das Vendas correspondentes (faturação das encomendas)
INSERT INTO public.vendas (id_encomenda) 
VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10);





SELECT 
    v.id_venda AS "Nº Fatura",
    c.nome AS "Cliente",
    p.nome_produto AS "Produto Sliq",
    e.quantidade AS "Qtd",
    (e.quantidade * p.preco) AS "Total Pago",
    c.morada AS "Destino de Envio"
FROM public.vendas v
JOIN public.encomendas e ON v.id_encomenda = e.id_encomenda
JOIN public.clientes c ON e.id_clientes = c.id_clientes
JOIN public.produtos p ON e.id_produto = p.id_produto;

--1. Relatório de Faturação Total (Quanto dinheiro ganhaste)
SELECT 
    SUM(e.quantidade * p.preco) AS "Faturação Total (€)",
    COUNT(v.id_venda) AS "Total de Vendas Realizadas"
FROM public.vendas v
JOIN public.encomendas e ON v.id_encomenda = e.id_encomenda
JOIN public.produtos p ON e.id_produto = p.id_produto;

-- 2. Ranking de Produtos Mais Vendidos
SELECT 
    p.nome_produto AS "Produto/Acessório",
    SUM(e.quantidade) AS "Unidades Vendidas",
    SUM(e.quantidade * p.preco) AS "Total Gerado (€)"
FROM public.encomendas e
JOIN public.produtos p ON e.id_produto = p.id_produto
GROUP BY p.nome_produto
ORDER BY "Unidades Vendidas" DESC;

--3. Análise de Vendas por Cidade (Destino)
SELECT 
    SUBSTRING(c.morada FROM ', (.*)$') AS "Cidade",
    COUNT(v.id_venda) AS "Número de Vendas",
    SUM(e.quantidade * p.preco) AS "Total Faturado por Região (€)"
FROM public.vendas v
JOIN public.encomendas e ON v.id_encomenda = e.id_encomenda
JOIN public.clientes c ON e.id_clientes = c.id_clientes
JOIN public.produtos p ON e.id_produto = p.id_produto
GROUP BY "Cidade"
ORDER BY "Número de Vendas" DESC;

--5. Alerta de Stock Baixo
SELECT 
    nome_produto AS "Produto Necessita Reposição",
    stock AS "Stock Atual",
    acessorios AS "Detalhes"
FROM public.produtos
WHERE stock < 55
ORDER BY stock ASC;

--6. Procurar Clientes por Domínio de Email 
SELECT nome, email, telemovel 
FROM public.clientes
WHERE email LIKE '%@email.com' ;

-- 7. Encontrar Clientes que Gastaram Acima da Média
  SELECT 
    c.nome AS "Cliente VIP",
    (e.quantidade * p.preco) AS "Total Gasto (€)"
FROM public.encomendas e
JOIN public.clientes c ON e.id_clientes = c.id_clientes
JOIN public.produtos p ON e.id_produto = p.id_produto
WHERE (e.quantidade * p.preco) > (
    SELECT AVG(enc.quantidade * prod.preco) 
    FROM public.encomendas enc
    JOIN public.produtos prod ON enc.id_produto = prod.id_produto
)
ORDER BY "Total Gasto (€)" DESC;




