-- ========================================================
-- SISTEMA SAP WMS OBRA - ESQUEMA DE BASE DE DATOS
-- ========================================================

DROP TABLE IF EXISTS avisos_mantenimiento CASCADE;
DROP TABLE IF EXISTS movimientos_almacen CASCADE;
DROP TABLE IF EXISTS equipos_serie CASCADE;
DROP TABLE IF EXISTS materiales CASCADE;
DROP TABLE IF EXISTS proyectos_pep CASCADE;
DROP TABLE IF EXISTS trabajadores CASCADE;

CREATE TABLE trabajadores (
    id VARCHAR(20) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    cargo VARCHAR(50) NOT NULL,
    estado VARCHAR(20) DEFAULT 'ACTIVO' CHECK (estado IN ('ACTIVO', 'INACTIVO', 'BLOQUEADO'))
);

CREATE TABLE proyectos_pep (
    codigo VARCHAR(50) PRIMARY KEY,
    nombre_proyecto VARCHAR(100) NOT NULL,
    residente_responsable VARCHAR(100) NOT NULL,
    presupuesto_disponible DECIMAL(12,2) DEFAULT 100000.00
);

CREATE TABLE materiales (
    id VARCHAR(20) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('HERRAMIENTA', 'CONSUMIBLE')),
    requiere_serie BOOLEAN DEFAULT FALSE,
    unidad_medida VARCHAR(10) NOT NULL DEFAULT 'UN',
    stock_actual INT DEFAULT 0,
    ubicacion_predeterminada VARCHAR(50) NOT NULL
);

CREATE TABLE equipos_serie (
    numero_serie VARCHAR(50) PRIMARY KEY,
    material_id VARCHAR(20) REFERENCES materiales(id) ON DELETE CASCADE,
    estado VARCHAR(20) DEFAULT 'DISPONIBLE' CHECK (estado IN ('DISPONIBLE', 'PRESTADO', 'MANTENIMIENTO', 'BAJA')),
    ubicacion_actual VARCHAR(50) NOT NULL,
    poseedor_actual_id VARCHAR(20) REFERENCES trabajadores(id) ON DELETE SET NULL,
    fecha_ultimo_mantenimiento DATE
);

CREATE TABLE movimientos_almacen (
    id SERIAL PRIMARY KEY,
    tipo_movimiento VARCHAR(20) NOT NULL CHECK (tipo_movimiento IN ('DESPACHO', 'DEVOLUCION')),
    doc_sap VARCHAR(30) NOT NULL,
    trabajador_id VARCHAR(20) REFERENCES trabajadores(id),
    elemento_pep VARCHAR(50) REFERENCES proyectos_pep(codigo),
    material_id VARCHAR(20) REFERENCES materiales(id),
    numero_serie VARCHAR(50) REFERENCES equipos_serie(numero_serie),
    cantidad INT DEFAULT 1,
    condicion_entrega VARCHAR(30) CHECK (condicion_entrega IN ('OPERATIVO', 'REQUIERE_MANTENIMIENTO', 'DANO_POR_USO', 'N/A')),
    observaciones TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE avisos_mantenimiento (
    id SERIAL PRIMARY KEY,
    numero_aviso VARCHAR(20) UNIQUE NOT NULL,
    numero_serie VARCHAR(50) REFERENCES equipos_serie(numero_serie),
    motivo VARCHAR(50) NOT NULL,
    detalles TEXT,
    estado VARCHAR(20) DEFAULT 'PENDIENTE' CHECK (estado IN ('PENDIENTE', 'EN_REPARACION', 'CERRADO')),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- SEED DATA
INSERT INTO trabajadores (id, nombre, cargo) VALUES
('70482910', 'Carlos Mendoza', 'Capataz de Estructuras'),
('45109283', 'Jorge Ríos', 'Operario Electricista'),
('10293847', 'Sonia Alva', 'Topógrafa Senior');

INSERT INTO proyectos_pep (codigo, nombre_proyecto, residente_responsable) VALUES
('PEP-2026-OBRA-NORTE-01', 'Edificio Torre Norte - Fase 1', 'Ing. Roberto Gómez'),
('PEP-2026-SANEAMIENTO-02', 'Red de Agua y Alcantarillado Sector 4', 'Ing. Laura Páez');

INSERT INTO materiales (id, nombre, tipo, requiere_serie, unidad_medida, stock_actual, ubicacion_predeterminada) VALUES
('MAT-101', 'Rotomartillo DeWalt 20V XR', 'HERRAMIENTA', TRUE, 'UN', 3, 'ALM1-RACK-A02'),
('MAT-102', 'Amoladora Angular Makita 7"', 'HERRAMIENTA', TRUE, 'UN', 2, 'ALM1-RACK-B01'),
('MAT-103', 'Estación Total Leica TS07 Laser', 'HERRAMIENTA', TRUE, 'UN', 2, 'ALM1-JAULA-01'),
('MAT-201', 'Disco de Corte para Concreto 7"', 'CONSUMIBLE', FALSE, 'UN', 150, 'ALM2-ESTANTE-04'),
('MAT-202', 'Casco de Seguridad Dielectrico Blanco', 'CONSUMIBLE', FALSE, 'UN', 45, 'ALM2-ESTANTE-01');

INSERT INTO equipos_serie (numero_serie, material_id, estado, ubicacion_actual) VALUES
('DW-981234', 'MAT-101', 'DISPONIBLE', 'ALM1-RACK-A02'),
('DW-981235', 'MAT-101', 'DISPONIBLE', 'ALM1-RACK-A02'),
('MK-772110', 'MAT-102', 'DISPONIBLE', 'ALM1-RACK-B01'),
('LC-554100', 'MAT-103', 'DISPONIBLE', 'ALM1-JAULA-01');
