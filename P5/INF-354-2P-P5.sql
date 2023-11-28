---Creamos la tabla comparacion donde se almacenaran los distintos resultados de la comparacion de cadenas
CREATE TABLE comparacion (
    -- Este atributo almacenara la primera cadena
    cadena_1 NVARCHAR(2000),
    -- Este atributo almacenara la segunda cadena
    cadena_2 NVARCHAR(2000),
    -- Este atributo almacenara la cantidad de caracteres que tienen ambas cadeas
    caracteres INT,
    -- mostrara el porcentaje de similitud de las cadenas
    similitud DECIMAL(5, 2)
);

-- Creamos el procedimiento almacenado
CREATE PROCEDURE comparar_cadenas
    -- Este parametro almacenara la primera cadena
    @cadena1 NVARCHAR(2000),
    -- Este parametro almacenara la segunda cadena
    @cadena2 NVARCHAR(2000)
AS
BEGIN
    -- declararemos las variables que utilizaremos
    DECLARE @longitud_cadena1 INT, @longitud_cadena2 INT
    -- declararemos las variables sobre las cuales iteraremos para comparar las cadenas
    DECLARE @i INT, @j INT, @caracter_cadena1 NCHAR, @c INT, @c_temp INT
    -- declararemos las variables que almacenaran los vectores binarios
    DECLARE @cv0 VARBINARY(8000), @cv1 VARBINARY(8000)

    -- Iniciaremos las variables
    SELECT
        -- obtenemos la longitud de la primera cadena
        @longitud_cadena1 = LEN(@cadena1),
        -- obtenemos la longitud de la segunda cadena
        @longitud_cadena2 = LEN(@cadena2),
        -- inicializamos el vector binario
        @cv1 = 0x0000,
        -- inicializamos las variables de iteracion
        @j = 1, @i = 1, @c = 0

    -- Crearemos un vector binario que representa la longitud de la segunda cadena
    WHILE @j <= @longitud_cadena2
        SELECT @cv1 = @cv1 + CAST(@j AS binary(2)), @j = @j + 1

    -- Bucle principal para calcular la distancia
    WHILE @i <= @longitud_cadena1
    BEGIN
        SELECT
            -- obtenemos el caracter de la primera cadena
            @caracter_cadena1 = SUBSTRING(@cadena1, @i, 1),
            -- inicializamos la variable de distancia
            @c = @i,
            -- inicializamos el vector binario
            @cv0 = CAST(@i AS binary(2)),
            -- inicializamos la variable de iteracion
            @j = 1

        WHILE @j <= @longitud_cadena2
        BEGIN
            -- calculamos la distancia
            SET @c = @c + 1
            --  calculamos la distancia de la cadena
            SET @c_temp = CAST(SUBSTRING(@cv1, @j + @j - 1, 2) AS INT) +
                CASE WHEN @caracter_cadena1 = SUBSTRING(@cadena2, @j, 1) THEN 0 ELSE 1 END
            IF @c > @c_temp SET @c = @c_temp
            SET @c_temp = CAST(SUBSTRING(@cv1, @j + @j + 1, 2) AS INT) + 1
            IF @c > @c_temp SET @c = @c_temp
            SELECT @cv0 = @cv0 + CAST(@c AS binary(2)), @j = @j + 1
        END

        -- Actualizar el vector binario
        SELECT @cv1 = @cv0, @i = @i + 1
    END

    -- Calcular el porcentaje de similitud entre las cadenas
    DECLARE @longitud_maxima INT, @porcentaje DECIMAL(5, 2)
    -- obtenemos la longitud maxima entre las cadenas
    SELECT @longitud_maxima = CASE WHEN @longitud_cadena1 > @longitud_cadena2 THEN @longitud_cadena1 ELSE @longitud_cadena2 END
    -- calculamos el porcentaje de similitud
    SET @porcentaje = ROUND(100.0 - ((CAST(@c AS DECIMAL(5, 2)) / @longitud_maxima) * 100.0), 2)

    -- Insertar en la tabla de resultados
    INSERT INTO comparacion (cadena_1, cadena_2, caracteres, similitud)
    VALUES (@cadena1, @cadena2, @c, @porcentaje)
END

-- mostramos la tabla de resultados
SELECT * FROM comparacion;
-- ejecutamos el procedimiento almacenado para los datos de ejemplo
EXEC comparar_cadenas 'maria', 'naria'
EXEC comparar_cadenas 'jefe', 'geffe'
EXEC comparar_cadenas 'massiel', 'masiel'
EXEC comparar_cadenas 'brandom', 'brandon'
EXEC comparar_cadenas 'tarjeta', 'targeta'
EXEC comparar_cadenas 'alcohol', 'alcol'
-- mostramos la tabla de resultados
SELECT * FROM comparacion;