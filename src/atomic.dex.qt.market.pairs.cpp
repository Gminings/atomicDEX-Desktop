/******************************************************************************
 * Copyright © 2013-2019 The Komodo Platform Developers.                      *
 *                                                                            *
 * See the AUTHORS, DEVELOPER-AGREEMENT and LICENSE files at                  *
 * the top-level directory of this distribution for the individual copyright  *
 * holder information and the developer policies on copyright and licensing.  *
 *                                                                            *
 * Unless otherwise agreed in a custom licensing agreement, no part of the    *
 * Komodo Platform software, including this file may be copied, modified,     *
 * propagated or distributed except according to the terms contained in the   *
 * LICENSE file                                                               *
 *                                                                            *
 * Removal or modification of this copyright notice is prohibited.            *
 *                                                                            *
 ******************************************************************************/

#include "atomic.dex.qt.market.pairs.hpp"

namespace atomic_dex
{
    market_pairs::market_pairs(portfolio_model* portfolio_mdl, QObject* parent) :
        QObject(parent), m_left_selection_box(new portfolio_proxy_model(portfolio_mdl)), m_right_selection_box(new portfolio_proxy_model(portfolio_mdl))
    {
        //set_left_selected_coin("KMD");
        m_left_selection_box->setSourceModel(portfolio_mdl);
        m_left_selection_box->setFilterRole(portfolio_model::Excluded);
        m_left_selection_box->setDynamicSortFilter(true);
        m_left_selection_box->sort_by_currency_balance(false);

        //set_right_selected_coin("BTC");
        m_right_selection_box->setSourceModel(portfolio_mdl);
        m_right_selection_box->setFilterRole(portfolio_model::Excluded);
        m_right_selection_box->setDynamicSortFilter(true);
        m_right_selection_box->sort_by_currency_balance(false);
    }
    market_pairs::~market_pairs() noexcept {}
} // namespace atomic_dex

//! Properties implementation
namespace atomic_dex
{
    QString
    market_pairs::get_left_selected_coin() const noexcept
    {
        return m_left_selected_coin;
    }

    QString
    market_pairs::get_right_selected_coin() const noexcept
    {
        return m_right_selected_coin;
    }

    void
    market_pairs::set_left_selected_coin(QString left_coin) noexcept
    {
        if (left_coin != m_left_selected_coin)
        {
            m_left_selected_coin = std::move(left_coin);
            auto res_left = m_left_selection_box->match(m_left_selection_box->index(0, 0), portfolio_model::PortfolioRoles::TickerRole, m_left_selected_coin);
            assert(not res_left.empty());
            m_left_selection_box->setData(res_left.at(0), portfolio_model::PortfolioRoles::Excluded, true);
            emit leftSelectedCoinChanged();
        }
    }

    void
    market_pairs::set_right_selected_coin(QString right_coin) noexcept
    {
        if (right_coin != m_right_selected_coin)
        {
            m_right_selected_coin = std::move(right_coin);
            auto res_right = m_right_selection_box->match(m_right_selection_box->index(0, 0), portfolio_model::PortfolioRoles::TickerRole, m_right_selected_coin);
            assert(not res_right.empty());
            m_right_selection_box->setData(res_right.at(0), portfolio_model::PortfolioRoles::Excluded, true);
            emit rightSelectedCoinChanged();
        }
    }

    portfolio_proxy_model* market_pairs::get_left_selection_box() const noexcept
    {
        return m_left_selection_box;
    }

    portfolio_proxy_model* market_pairs::get_right_selection_box() const noexcept
    {
        return m_right_selection_box;
    }
} // namespace atomic_dex

//! public API
namespace atomic_dex
{
} // namespace atomic_dex