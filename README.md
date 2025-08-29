**Bookmyshow**

**Objective**

The goal of this assignment is to design a relational database schema
for an online movie ticket booking platform similar to BookMyShow. The
system is intended to handle core operations such as managing movies,
theatres, screens, seat layouts, show schedules, customer registrations,
and seat-level ticket bookings. The design ensures high data integrity
and adheres to normalization principles to avoid redundancy.

**Schema Overview**

The schema consists of eight well-structured tables. Each table is
normalized up to Boyce-Codd Normal Form (BCNF) and is designed to
reflect the real-world relationships between entities. Below is a
summary of the purpose of each table:

  ----------------------------------------------------------------------------
  **Table**     **Description**
  ------------- --------------------------------------------------------------
  movie         Stores details about movies, including title, language, genre,
                certificate, and IMDb rating.

  theatre       Represents physical theatres, including name, location, and
                address details.

  screen        Represents individual screens/auditoriums within a theatre,
                including screen number, audio system, and screen type.

  seat          Defines the seating layout for each screen, including seat
                label, row, column, and class.

  showtime      Represents scheduled screenings of a movie on a specific
                screen at a specific time, with optional subtitle information.

  customer      Stores customer registration information, including name,
                email, mobile number, and registration timestamp.

  ticket        Represents a booking transaction made by a customer for a
                specific show, including payment status and total amount.

  ticket_seat   Contains line items for each seat booked under a ticket,
                ensuring seat-level traceability and preventing duplicate
                bookings.
  ----------------------------------------------------------------------------

**Data Integrity and Constraints**

-   All tables use primary keys to uniquely identify records.

-   Foreign key constraints are implemented to maintain referential
    integrity between related entities.

-   Unique constraints are used where necessary to prevent duplication,
    such as preventing the same seat from being booked more than once
    for a show.

-   Enum types are used to restrict values for attributes like
    certificate and payment_status, improving data consistency.

-   The ticket_seat table includes show_id to enable a direct uniqueness
    constraint on (show_id, seat_id), which enforces seat-level
    exclusivity per show.

**Normalization Compliance**

-   All tables are in **First Normal Form (1NF)** -- atomic values are
    stored in each column.

-   **Second Normal Form (2NF)** is ensured by eliminating partial
    dependencies.

-   **Third Normal Form (3NF)** is achieved by removing transitive
    dependencies.

-   **Boyce-Codd Normal Form (BCNF)** compliance is maintained by
    ensuring that every determinant is a candidate key.

**ER Diagram**

An entity-relationship diagram has been generated to visually represent
the schema, including all relationships, primary keys, and foreign keys.
This diagram clearly illustrates how entities such as movies, screens,
customers, and tickets are connected.

<img width="960" height="424" alt="bookmyshow_er_diagram" src="https://github.com/user-attachments/assets/c3e445e1-2439-463c-b6a7-926e3b40289f" />

**Design Highlights**

-   Supports multi-seat bookings per ticket while maintaining a single
    transaction record.

-   Prevents double booking of the same seat in the same show through
    declarative database constraints.

-   Modular and extensible structure, suitable for future enhancements
    such as pricing models, promotional offers, and seat availability
    tracking.

-   Designed using best practices in relational modeling and
    normalization.

**P1**

**Tables and Attributes**

**1) Movie**

-   **movie_id** (PK)

-   **title**

-   **language**

-   **certificate** (e.g., UA)

-   **duration_min**

-   **genre**

-   **release_date**

-   **imdb_rating**

    -   **FDs:** movie_id → all other attrs

> **2) Theatre**

-   **theatre_id** (PK)

-   **name**

-   **address_line**

-   **city**

-   **state**

-   **pincode**

    -   **FDs:** theatre_id → all other attrs

**3) Screen**

-   **screen_id** (PK)

-   **theatre_id** (FK → Theatre.theatre_id)

-   **screen_number**

-   **audio_system**

-   **screen_type**

    -   **FDs:** screen_id

**4) Seat (physical seat master for a screen)**

-   **seat_id** (PK)

-   **screen_id** (FK → Screen.screen_id)

-   **seat_label**

    -   **UQ:** (screen_id, seat_label)

    -   **FDs:** seat_id → screen_id, seat_label

**5) Show Time**

-   **show_id** (PK)

-   **movie_id** (FK → Movie.movie_id)

-   **screen_id** (FK → Screen.screen_id)

-   **start_datetime**

    -   **UQ:** (screen_id, start_datetime)

    -   **FDs:** show_id → movie_id, screen_id, start_datetime

**6) Customer**

-   **customer_id** (PK)

-   **full_name**

-   **email**

-   **mobile_number**

-   **created_at**

    -   **UQ:** email, mobile_number

    -   **FDs:** customer_id → full_name, email, mobile_number

**7) Ticket**

-   **ticket_id** (PK)

-   **show_id** (FK → Show.show_id)

-   **customer_id** (FK → Customer.customer_id)

-   **booked_at**

-   **payment_status**

-   **total_amount**

    -   **FDs:** ticket_id → show_id, customer_id

**8) TicketSeat**

-   **ticket_id** (FK → Ticket.ticket_id)

-   **show_id** (FK → Show.show_id)

-   **seat_id** (FK → Seat.seat_id)

    -   **PK:** (ticket_id, seat_id)

    -   **UQ:** (show_id, seat_id)

    -   **FDs:** (ticket_id, seat_id) → show_id; and (show_id, seat_id)
        determines "booked"

**SQL Commands**

**Create commands**

CREATE TABLE movie (movie_id BIGINT PRIMARY KEY AUTO_INCREMENT, title
VARCHAR(200) NOT NULL, language VARCHAR(50) NOT NULL, certificate
ENUM(\'U\', \'UA\', \'A\', \'S\') DEFAULT NULL, duration_min SMALLINT
NOT NULL CHECK (duration_min \> 0), genre VARCHAR(100), release_date
DATE, imdb_rating DECIMAL(3,1) CHECK (imdb_rating BETWEEN 0.0 AND 10.0),
UNIQUE KEY uq_movie_identity (title, language, release_date));

CREATE TABLE theatre (theatre_id BIGINT PRIMARY KEY AUTO_INCREMENT, name
VARCHAR(150) NOT NULL, address_line VARCHAR(255), city VARCHAR(100) NOT
NULL, state VARCHAR(100), pincode VARCHAR(20), UNIQUE KEY
uq_theatre_name_city (name, city));

CREATE TABLE screen (screen_id BIGINT PRIMARY KEY AUTO_INCREMENT,
theatre_id BIGINT NOT NULL, screen_number VARCHAR(50) NOT NULL,
audio_system VARCHAR(50) NOT NULL, screen_type VARCHAR(50) NOT NULL,
UNIQUE KEY uq_theatre_screen_number (theatre_id, screen_number),
CONSTRAINT fk_screen_theatre FOREIGN KEY (theatre_id) REFERENCES
theatre(theatre_id) ON DELETE CASCADE);

CREATE TABLE seat (seat_id BIGINT PRIMARY KEY AUTO_INCREMENT, screen_id
BIGINT NOT NULL, seat_label VARCHAR(10) NOT NULL, UNIQUE KEY
uq_screen_seat (screen_id, seat_label), CONSTRAINT fk_seat_screen
FOREIGN KEY (screen_id) REFERENCES screen(screen_id) ON DELETE CASCADE);

CREATE TABLE showtime (show_id BIGINT PRIMARY KEY AUTO_INCREMENT,
movie_id BIGINT NOT NULL, screen_id BIGINT NOT NULL, start_datetime
DATETIME NOT NULL, subtitle_available BOOLEAN DEFAULT FALSE,
subtitle_language VARCHAR(50), UNIQUE KEY uq_show_screen_start
(screen_id, start_datetime), CONSTRAINT fk_show_movie FOREIGN KEY
(movie_id) REFERENCES movie(movie_id) ON DELETE RESTRICT, CONSTRAINT
fk_show_screen FOREIGN KEY (screen_id) REFERENCES screen(screen_id) ON
DELETE RESTRICT);

CREATE TABLE customer (customer_id BIGINT PRIMARY KEY AUTO_INCREMENT,
full_name VARCHAR(150) NOT NULL, email VARCHAR(200) NOT NULL,
mobile_number VARCHAR(20) NOT NULL, created_at DATETIME NOT NULL DEFAULT
CURRENT_TIMESTAMP, UNIQUE KEY uq_customer_email (email), UNIQUE KEY
uq_customer_mobile (mobile_number));

CREATE TABLE ticket (ticket_id BIGINT PRIMARY KEY AUTO_INCREMENT,
show_id BIGINT NOT NULL, customer_id BIGINT NOT NULL, booked_at DATETIME
NOT NULL DEFAULT CURRENT_TIMESTAMP, payment_status ENUM(\'PENDING\',
\'PAID\', \'FAILED\', \'REFUNDED\') NOT NULL DEFAULT \'PENDING\',
total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00, CONSTRAINT
fk_ticket_show FOREIGN KEY (show_id) REFERENCES showtime(show_id) ON
DELETE RESTRICT, CONSTRAINT fk_ticket_customer FOREIGN KEY (customer_id)
REFERENCES customer(customer_id) ON DELETE RESTRICT);

CREATE TABLE ticket_seat (ticket_id BIGINT NOT NULL, show_id BIGINT NOT
NULL, seat_id BIGINT NOT NULL, PRIMARY KEY (ticket_id, seat_id),
CONSTRAINT fk_tseat_ticket FOREIGN KEY (ticket_id) REFERENCES
ticket(ticket_id) ON DELETE CASCADE, CONSTRAINT fk_tseat_show FOREIGN
KEY (show_id) REFERENCES showtime(show_id) ON DELETE RESTRICT,
CONSTRAINT fk_tseat_seat FOREIGN KEY (seat_id) REFERENCES seat(seat_id)
ON DELETE RESTRICT, UNIQUE KEY uq_show_seat_once (show_id, seat_id));

**Insert**

INSERT INTO movie (title, language, certificate, duration_min, genre,
release_date, imdb_rating) VALUES (\'Inception\', \'English\', \'UA\',
148, \'Sci-Fi\', \'2010-07-16\', 8.8);\
INSERT INTO movie (title, language, certificate, duration_min, genre,
release_date, imdb_rating) VALUES (\'3 Idiots\', \'Hindi\', \'U\', 171,
\'Drama\', \'2009-12-25\', 8.4);\
INSERT INTO theatre (name, address_line, city, state, pincode) VALUES
(\'PVR Cinemas\', \'123 Main Road\', \'Chennai\', \'Tamil Nadu\',
\'600001\');\
INSERT INTO theatre (name, address_line, city, state, pincode) VALUES
(\'INOX\', \'45 Arcot Road\', \'Bengaluru\', \'Karnataka\',
\'560001\');\
INSERT INTO screen (theatre_id, screen_number, audio_system,
screen_type) VALUES (1, \'Screen 1\', \'Dolby Atmos\', \'IMAX\');\
INSERT INTO screen (theatre_id, screen_number, audio_system,
screen_type) VALUES (2, \'Screen 2\', \'7.1\', \'3D\');\
INSERT INTO seat (screen_id, seat_label) VALUES (1, \'A1\');\
INSERT INTO seat (screen_id, seat_label) VALUES (1, \'A2\');\
INSERT INTO seat (screen_id, seat_label) VALUES (2, \'B1\');\
INSERT INTO seat (screen_id, seat_label) VALUES (2, \'B2\');\
INSERT INTO showtime (movie_id, screen_id, start_datetime,
subtitle_available, subtitle_language) VALUES (1, 1, \'2025-09-01
18:00:00\', TRUE, \'Hindi\');\
INSERT INTO showtime (movie_id, screen_id, start_datetime,
subtitle_available, subtitle_language) VALUES (2, 2, \'2025-09-01
21:00:00\', FALSE, NULL);\
INSERT INTO customer (full_name, email, mobile_number) VALUES (\'Ram
A\', \'rama@gmail.com\', \'9876543210\');\
INSERT INTO customer (full_name, email, mobile_number) VALUES (\'Vishnu
K\', \'vishnu@yahoo.com\', \'9123456789\');\
INSERT INTO ticket (show_id, customer_id, payment_status, total_amount)
VALUES (1, 1, \'PAID\', 500.00);\
INSERT INTO ticket (show_id, customer_id, payment_status, total_amount)
VALUES (2, 2, \'PAID\', 600.00);\
INSERT INTO ticket_seat (ticket_id, show_id, seat_id) VALUES (1, 1, 1);\
INSERT INTO ticket_seat (ticket_id, show_id, seat_id) VALUES (1, 1, 2);\
INSERT INTO ticket_seat (ticket_id, show_id, seat_id) VALUES (2, 2, 3);\
INSERT INTO ticket_seat (ticket_id, show_id, seat_id) VALUES (2, 2, 4);

**P2**

Query to list down all the shows on a given date at a given theatre
along with their respective show timings.

SELECT m.title AS movie_name,s.screen_number,st.start_datetime FROM
showtime st JOIN movie m ON st.movie_id=m.movie_id JOIN screen s ON
st.screen_id=s.screen_id JOIN theatre t ON s.theatre_id=t.theatre_id
WHERE t.theatre_id=1 AND DATE(st.start_datetime)=\'2025-09-01\' ORDER BY
st.start_datetime;

The screenshot below displays the query results based on the sample
insert statements above.
<img width="922" height="255" alt="image" src="https://github.com/user-attachments/assets/0b974f22-2373-49d5-ae90-65c5930096b3" />
