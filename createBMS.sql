CREATE TABLE movie (
  movie_id      BIGINT PRIMARY KEY AUTO_INCREMENT,
  title         VARCHAR(200)    NOT NULL,
  language      VARCHAR(50)     NOT NULL,
  certificate   ENUM('U', 'UA', 'A', 'S') DEFAULT NULL,
  duration_min  SMALLINT        NOT NULL CHECK (duration_min > 0),
  genre         VARCHAR(100),
  release_date  DATE,
  imdb_rating   DECIMAL(3,1)    CHECK (imdb_rating BETWEEN 0.0 AND 10.0),

  UNIQUE KEY uq_movie_identity (title, language, release_date)
);

CREATE TABLE theatre (
  theatre_id     BIGINT PRIMARY KEY AUTO_INCREMENT,
  name           VARCHAR(150)   NOT NULL,
  address_line   VARCHAR(255),
  city           VARCHAR(100)   NOT NULL,
  state          VARCHAR(100),
  pincode        VARCHAR(20),

  UNIQUE KEY uq_theatre_name_city (name, city)
);


CREATE TABLE screen (
  screen_id       BIGINT PRIMARY KEY AUTO_INCREMENT,
  theatre_id      BIGINT       NOT NULL,
  screen_number   VARCHAR(50)  NOT NULL,  -- e.g., 'Screen 1', 'Audi 2'
  audio_system    VARCHAR(50)  NOT NULL,  -- e.g., '5.1', '7.1', 'Dolby Atmos'
  screen_type     VARCHAR(50)  NOT NULL,  -- e.g., '2D', '3D', 'IMAX',

  UNIQUE KEY uq_theatre_screen_number (theatre_id, screen_number),

  CONSTRAINT fk_screen_theatre
    FOREIGN KEY (theatre_id) REFERENCES theatre(theatre_id)
    ON DELETE CASCADE
);

CREATE TABLE seat (
  seat_id     BIGINT PRIMARY KEY AUTO_INCREMENT,
  screen_id   BIGINT       NOT NULL,
  seat_label  VARCHAR(10)  NOT NULL,
  UNIQUE KEY uq_screen_seat (screen_id, seat_label),

  CONSTRAINT fk_seat_screen
    FOREIGN KEY (screen_id) REFERENCES screen(screen_id)
    ON DELETE CASCADE
);

CREATE TABLE showtime (
  show_id             BIGINT PRIMARY KEY AUTO_INCREMENT,
  movie_id            BIGINT       NOT NULL,
  screen_id           BIGINT       NOT NULL,
  start_datetime      DATETIME     NOT NULL,
  subtitle_available  BOOLEAN      DEFAULT FALSE,
  subtitle_language   VARCHAR(50),

  UNIQUE KEY uq_show_screen_start (screen_id, start_datetime),

  CONSTRAINT fk_show_movie
    FOREIGN KEY (movie_id) REFERENCES movie(movie_id)
    ON DELETE RESTRICT,

  CONSTRAINT fk_show_screen
    FOREIGN KEY (screen_id) REFERENCES screen(screen_id)
    ON DELETE RESTRICT
);

CREATE TABLE customer (
  customer_id     BIGINT PRIMARY KEY AUTO_INCREMENT,
  full_name       VARCHAR(150)   NOT NULL,
  email           VARCHAR(200)   NOT NULL,
  mobile_number   VARCHAR(20)    NOT NULL,
  created_at      DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,

  UNIQUE KEY uq_customer_email (email),
  UNIQUE KEY uq_customer_mobile (mobile_number)
);

CREATE TABLE ticket (
  ticket_id      BIGINT PRIMARY KEY AUTO_INCREMENT,
  show_id        BIGINT       NOT NULL,
  customer_id    BIGINT       NOT NULL,
  booked_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  payment_status ENUM('PENDING', 'PAID', 'FAILED', 'REFUNDED') NOT NULL DEFAULT 'PENDING',
  total_amount   DECIMAL(10,2) NOT NULL DEFAULT 0.00,

  CONSTRAINT fk_ticket_show
    FOREIGN KEY (show_id) REFERENCES showtime(show_id)
    ON DELETE RESTRICT,

  CONSTRAINT fk_ticket_customer
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
    ON DELETE RESTRICT
);

CREATE TABLE ticket_seat (
  ticket_id   BIGINT NOT NULL,
  show_id     BIGINT NOT NULL,
  seat_id     BIGINT NOT NULL,

  PRIMARY KEY (ticket_id, seat_id),

  CONSTRAINT fk_tseat_ticket
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id)
    ON DELETE CASCADE,

  CONSTRAINT fk_tseat_show
    FOREIGN KEY (show_id) REFERENCES showtime(show_id)
    ON DELETE RESTRICT,

  CONSTRAINT fk_tseat_seat
    FOREIGN KEY (seat_id) REFERENCES seat(seat_id)
    ON DELETE RESTRICT,

  UNIQUE KEY uq_show_seat_once (show_id, seat_id)
);

