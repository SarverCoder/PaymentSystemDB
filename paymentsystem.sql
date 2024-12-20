create schema auth;

CREATE TYPE user_role_enum AS ENUM ('customer', 'merchant');

create table auth.users(
    user_id int primary key generated always as identity,
    name varchar(50) not null,
    email varchar(255) unique,
    password_hash varchar(255) not null,
    phone_numb varchar(100) not null,
    user_role user_role_enum not null default 'customer',
    created_at timestamp default now(),
    update_at timestamp null
);

create table auth.roles(
    role_id int primary key,
    role_name varchar(100) unique not null
);

create table auth.user_roles
(
    user_role_id int primary key generated always as identity,
    user_id int references auth.users(user_id),
    role_id int references auth.roles(role_id)


);

create schema pay;

create type pay_type as ENUM('card','wallet','crypto','bank_transfer');

create table pay.payment_method(
    payment_method_id int primary key,
    user_id int,
    type pay_type not null default 'card',
    details jsonb,
    created_at timestamp not null default now(),
    updated_at timestamp null,
    foreign key (user_id) references auth.users(user_id)
);

create type tran_status_enum as enum('pending','completed','failed','refunded');

create table pay.transaction
(
    transaction_id int primary key,
    user_id int,
    amount_tran numeric(10,2),
    currency char(3) not null,
    status_tran tran_status_enum not null default 'pending',
    payment_method_id int,
    description text null,
    created_at timestamp not null default now(),
    updated_at timestamp,

    foreign key (user_id) references auth.users(user_id),
    foreign key (payment_method_id) references pay.payment_method(payment_method_id)
);

create type status_invoice_enum as enum('paid','unpaid','overdue');

create table pay.invoices(

    invoice_id int primary key,
    transaction_id int not null,
    business_id int not null ,
    customer_id int not null,
    amount_due numeric(10,2) not null,
    due_date date not null,
    status status_invoice_enum not null default 'unpaid',
    created_at timestamp default now(),
    update_at timestamp default null,
    foreign key (transaction_id) references pay.transaction(transaction_id),
    foreign key (business_id) references auth.users(user_id),
    foreign key (customer_id) references auth.users(user_id)
);

create type enum_frequency as enum('daily','weekly','monthly','yearly');
create type enum_status_subs as enum('active','inactive','canceled');

create table pay.subscription(
    subscription_id int primary key,
    user_id int not null references auth.users(user_id),
    plan_name varchar(50) not null,
    amount numeric(10,2) not null,
    frequency enum_frequency not null default 'monthly',
    next_billing_date date not null,
    status enum_status_subs not null default 'inactive',
    created_at timestamp not null default now(),
    updated_at timestamp null

);

create table pay.recurring_rule
(
    rule_id int primary key generated always as identity,
    subscription int not null references pay.subscription(subscription_id),
    frequency enum_frequency not null default 'monthly',
    next_execution timestamp not null
);

create schema fin;

create table fin.currencies
(
    currency_code char(3) primary key ,
    exchange_rate numeric(10,4) default 1.0000,
    updated_at timestamp not null default now()
);

create type enum_fee_type as enum('transaction', 'refund', 'withdrawal');

create table fin.fees(
    fee_id int primary key generated always as identity,
    fee_type enum_fee_type not null default 'refund',
    amount numeric(10,2),
    currency_code char(3) references fin.currencies(currency_code)

);

create type enum_sett_status as enum('pending','completed');

create table fin.settlements(
    settlement_id int primary key generated always as identity,
    user_id int references auth.users(user_id),
    amount numeric(10,2),
    currency_code char(3) references fin.currencies(currency_code),
    status enum_sett_status not null,
    created_at timestamp not null default now()

);

create type enum_ref_status as enum('initiated','completed','failed');

create table fin.refunds(
    refund_id int primary key generated always as identity,
    transaction_id int,
    amount numeric(10,2) not null ,
    reason text not null,
    status enum_ref_status not null default 'failed',
    created_at timestamp not null default now()
);

create schema noti;

create type enum_notif as enum('unread', 'read');

create table noti.notifications(
    notification_id int primary key generated always as identity,
    user_id int references auth.users(user_id),
    message text not null,
    status enum_notif not null default 'unread',
    created_at timestamp not null default now()
);

create table noti.user_preferences
(
    preference_id int primary key generated always as identity,
    user_id int references auth.users(user_id),
    notify_by_email boolean default true,
    notify_by_sms boolean default false,
    notify_by_push boolean default true
);

create schema set;

create table set.system_configurations(
    config_id int primary key generated always as identity,
    config_key varchar(255) not null unique ,
    config_value text not null
);

create table set.feature_toggles(
    feature_id int primary key,
    feature_name varchar(100) unique ,
    is_enabled boolean default false
);


create schema anal;

create table anal.audit_logs(
    log_id int primary key,
    user_id int references auth.users(user_id),
    action text not null,
    details jsonb not null,
    created_at timestamp not null default now()
);

create table anal.fraud_detection
(
    fraud_log_id int primary key,
    transaction_id int references pay.transaction(transaction_id),
    reason text not null,
    reviewed boolean default false,
    created_at timestamp
);

create table anal.transaction_metrics(
    metric_id int primary key,
    transaction_id int not null,
    processing_time interval,
    success_rate float
);

alter table anal.transaction_metrics
add constraint fk_transaction_id
foreign key (transaction_id)
references pay.transaction(transaction_id);

create table anal.user_activity(
    activity_id int primary key,
    user_id int not null,
    action text not null,
    act_timestamp timestamp default now(),

    foreign key (user_id) references auth.users(user_id)

);



