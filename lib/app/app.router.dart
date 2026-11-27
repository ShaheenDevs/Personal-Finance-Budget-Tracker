// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:flutter/foundation.dart' as _i10;
import 'package:flutter/material.dart' as _i9;
import 'package:flutter/material.dart';
import 'package:personal_finance_budget_tracker/repositories/local_finance_repository.dart'
    as _i11;
import 'package:personal_finance_budget_tracker/services/app_security_service.dart'
    as _i12;
import 'package:personal_finance_budget_tracker/ui/views/accounts/accounts_view.dart'
    as _i3;
import 'package:personal_finance_budget_tracker/ui/views/budgets/budgets_view.dart'
    as _i6;
import 'package:personal_finance_budget_tracker/ui/views/categories_tags/categories_tags_view.dart'
    as _i5;
import 'package:personal_finance_budget_tracker/ui/views/dashboard/dashboard_view.dart'
    as _i2;
import 'package:personal_finance_budget_tracker/ui/views/reports/reports_view.dart'
    as _i7;
import 'package:personal_finance_budget_tracker/ui/views/settings/settings_view.dart'
    as _i8;
import 'package:personal_finance_budget_tracker/ui/views/transactions/transactions_view.dart'
    as _i4;
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i13;

class Routes {
  static const dashboardView = '/';

  static const accountsView = '/accounts-view';

  static const transactionsView = '/transactions-view';

  static const categoriesTagsView = '/categories-tags-view';

  static const budgetsView = '/budgets-view';

  static const reportsView = '/reports-view';

  static const settingsView = '/settings-view';

  static const all = <String>{
    dashboardView,
    accountsView,
    transactionsView,
    categoriesTagsView,
    budgetsView,
    reportsView,
    settingsView,
  };
}

class StackedRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(
      Routes.dashboardView,
      page: _i2.DashboardView,
    ),
    _i1.RouteDef(
      Routes.accountsView,
      page: _i3.AccountsView,
    ),
    _i1.RouteDef(
      Routes.transactionsView,
      page: _i4.TransactionsView,
    ),
    _i1.RouteDef(
      Routes.categoriesTagsView,
      page: _i5.CategoriesTagsView,
    ),
    _i1.RouteDef(
      Routes.budgetsView,
      page: _i6.BudgetsView,
    ),
    _i1.RouteDef(
      Routes.reportsView,
      page: _i7.ReportsView,
    ),
    _i1.RouteDef(
      Routes.settingsView,
      page: _i8.SettingsView,
    ),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.DashboardView: (data) {
      final args = data.getArgs<DashboardViewArguments>(
        orElse: () => const DashboardViewArguments(),
      );
      return _i9.MaterialPageRoute<dynamic>(
        builder: (context) => _i2.DashboardView(key: args.key),
        settings: data,
      );
    },
    _i3.AccountsView: (data) {
      final args = data.getArgs<AccountsViewArguments>(
        orElse: () => const AccountsViewArguments(),
      );
      return _i9.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i3.AccountsView(key: args.key, repository: args.repository),
        settings: data,
      );
    },
    _i4.TransactionsView: (data) {
      final args = data.getArgs<TransactionsViewArguments>(
        orElse: () => const TransactionsViewArguments(),
      );
      return _i9.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i4.TransactionsView(key: args.key, repository: args.repository),
        settings: data,
      );
    },
    _i5.CategoriesTagsView: (data) {
      final args = data.getArgs<CategoriesTagsViewArguments>(
        orElse: () => const CategoriesTagsViewArguments(),
      );
      return _i9.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i5.CategoriesTagsView(key: args.key, repository: args.repository),
        settings: data,
      );
    },
    _i6.BudgetsView: (data) {
      final args = data.getArgs<BudgetsViewArguments>(
        orElse: () => const BudgetsViewArguments(),
      );
      return _i9.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i6.BudgetsView(key: args.key, repository: args.repository),
        settings: data,
      );
    },
    _i7.ReportsView: (data) {
      final args = data.getArgs<ReportsViewArguments>(
        orElse: () => const ReportsViewArguments(),
      );
      return _i9.MaterialPageRoute<dynamic>(
        builder: (context) => _i7.ReportsView(key: args.key),
        settings: data,
      );
    },
    _i8.SettingsView: (data) {
      final args = data.getArgs<SettingsViewArguments>(
        orElse: () => const SettingsViewArguments(),
      );
      return _i9.MaterialPageRoute<dynamic>(
        builder: (context) => _i8.SettingsView(
            key: args.key, securityService: args.securityService),
        settings: data,
      );
    },
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class DashboardViewArguments {
  const DashboardViewArguments({this.key});

  final _i10.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant DashboardViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class AccountsViewArguments {
  const AccountsViewArguments({
    this.key,
    this.repository,
  });

  final _i10.Key? key;

  final _i11.LocalFinanceRepository? repository;

  @override
  String toString() {
    return '{"key": "$key", "repository": "$repository"}';
  }

  @override
  bool operator ==(covariant AccountsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.repository == repository;
  }

  @override
  int get hashCode {
    return key.hashCode ^ repository.hashCode;
  }
}

class TransactionsViewArguments {
  const TransactionsViewArguments({
    this.key,
    this.repository,
  });

  final _i10.Key? key;

  final _i11.LocalFinanceRepository? repository;

  @override
  String toString() {
    return '{"key": "$key", "repository": "$repository"}';
  }

  @override
  bool operator ==(covariant TransactionsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.repository == repository;
  }

  @override
  int get hashCode {
    return key.hashCode ^ repository.hashCode;
  }
}

class CategoriesTagsViewArguments {
  const CategoriesTagsViewArguments({
    this.key,
    this.repository,
  });

  final _i10.Key? key;

  final _i11.LocalFinanceRepository? repository;

  @override
  String toString() {
    return '{"key": "$key", "repository": "$repository"}';
  }

  @override
  bool operator ==(covariant CategoriesTagsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.repository == repository;
  }

  @override
  int get hashCode {
    return key.hashCode ^ repository.hashCode;
  }
}

class BudgetsViewArguments {
  const BudgetsViewArguments({
    this.key,
    this.repository,
  });

  final _i10.Key? key;

  final _i11.LocalFinanceRepository? repository;

  @override
  String toString() {
    return '{"key": "$key", "repository": "$repository"}';
  }

  @override
  bool operator ==(covariant BudgetsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.repository == repository;
  }

  @override
  int get hashCode {
    return key.hashCode ^ repository.hashCode;
  }
}

class ReportsViewArguments {
  const ReportsViewArguments({this.key});

  final _i10.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant ReportsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class SettingsViewArguments {
  const SettingsViewArguments({
    this.key,
    this.securityService,
  });

  final _i10.Key? key;

  final _i12.AppSecurityService? securityService;

  @override
  String toString() {
    return '{"key": "$key", "securityService": "$securityService"}';
  }

  @override
  bool operator ==(covariant SettingsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.securityService == securityService;
  }

  @override
  int get hashCode {
    return key.hashCode ^ securityService.hashCode;
  }
}

extension NavigatorStateExtension on _i13.NavigationService {
  Future<dynamic> navigateToDashboardView({
    _i10.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.dashboardView,
        arguments: DashboardViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAccountsView({
    _i10.Key? key,
    _i11.LocalFinanceRepository? repository,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.accountsView,
        arguments: AccountsViewArguments(key: key, repository: repository),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToTransactionsView({
    _i10.Key? key,
    _i11.LocalFinanceRepository? repository,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.transactionsView,
        arguments: TransactionsViewArguments(key: key, repository: repository),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToCategoriesTagsView({
    _i10.Key? key,
    _i11.LocalFinanceRepository? repository,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.categoriesTagsView,
        arguments:
            CategoriesTagsViewArguments(key: key, repository: repository),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToBudgetsView({
    _i10.Key? key,
    _i11.LocalFinanceRepository? repository,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.budgetsView,
        arguments: BudgetsViewArguments(key: key, repository: repository),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToReportsView({
    _i10.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.reportsView,
        arguments: ReportsViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToSettingsView({
    _i10.Key? key,
    _i12.AppSecurityService? securityService,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.settingsView,
        arguments:
            SettingsViewArguments(key: key, securityService: securityService),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithDashboardView({
    _i10.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.dashboardView,
        arguments: DashboardViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAccountsView({
    _i10.Key? key,
    _i11.LocalFinanceRepository? repository,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.accountsView,
        arguments: AccountsViewArguments(key: key, repository: repository),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithTransactionsView({
    _i10.Key? key,
    _i11.LocalFinanceRepository? repository,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.transactionsView,
        arguments: TransactionsViewArguments(key: key, repository: repository),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithCategoriesTagsView({
    _i10.Key? key,
    _i11.LocalFinanceRepository? repository,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.categoriesTagsView,
        arguments:
            CategoriesTagsViewArguments(key: key, repository: repository),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithBudgetsView({
    _i10.Key? key,
    _i11.LocalFinanceRepository? repository,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.budgetsView,
        arguments: BudgetsViewArguments(key: key, repository: repository),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithReportsView({
    _i10.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.reportsView,
        arguments: ReportsViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithSettingsView({
    _i10.Key? key,
    _i12.AppSecurityService? securityService,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.settingsView,
        arguments:
            SettingsViewArguments(key: key, securityService: securityService),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }
}
